import 'dart:convert';
import 'dart:typed_data';
import 'package:fanfoot/core/enums/player.dart';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/models/player.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/core/services/player_csv_service.dart';
import 'package:fanfoot/core/services/player_service.dart';
import 'package:fanfoot/features/editor/widgets/header_editor.dart';
import 'package:fanfoot/features/player/new_player_page.dart';
import 'package:fanfoot/features/player/widgets/import_players_dialog.dart';
import 'package:fanfoot/features/editor/widgets/player_list_view.dart';
import 'package:fanfoot/features/editor/widgets/player_grid_view.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isGridView = false;
  final _csvService = PlayerCsvService();
  final _playerService = PlayerService();
  final _clubService = ClubService();
  final _countryService = CountryService();

  List<Player> _players = [];
  List<Club> _clubs = [];
  List<Country> _countries = [];
  bool _isLoading = true;

  String _searchQuery = '';
  Position? _selectedPosition;
  PlayerStatus? _selectedStatus;
  int? _selectedClubId;
  int? _selectedCountryId;
  int? _minOverall;
  int? _maxOverall;

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final players = await _playerService.getAllPlayers();
    final clubs = await _clubService.getAllClubs();
    final countries = await _countryService.getAllCountries();

    setState(() {
      _players = players;
      _clubs = clubs;
      _countries = countries;
      _isLoading = false;
    });
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    List<Player> filtered;

    if (_searchQuery.isEmpty &&
        _selectedPosition == null &&
        _selectedStatus == null &&
        _selectedClubId == null &&
        _selectedCountryId == null &&
        _minOverall == null &&
        _maxOverall == null) {
      filtered = await _playerService.getAllPlayers();
    } else {
      filtered = await _playerService.filterPlayers(
        name: _searchQuery.isEmpty ? null : _searchQuery,
        position: _selectedPosition,
        status: _selectedStatus,
        clubId: _selectedClubId,
        countryId: _selectedCountryId,
        minOverall: _minOverall,
        maxOverall: _maxOverall,
      );
    }

    setState(() {
      _players = filtered;
      _isLoading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedPosition = null;
      _selectedStatus = null;
      _selectedClubId = null;
      _selectedCountryId = null;
      _minOverall = null;
      _maxOverall = null;
    });
    _loadData();
  }

  Future<void> _exportPlayersCsv() async {
    if (_players.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum jogador para exportar')),
      );
      return;
    }

    final csvContent = _csvService.exportPlayersToCsv(_players);
    final fileName =
        'jogadores_export_${DateTime.now().millisecondsSinceEpoch}.csv';

    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        const XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );

    if (location == null) return;

    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(csvContent)),
      mimeType: 'text/csv',
      name: fileName,
    );

    await file.saveTo(location.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jogadores exportados para ${location.path}')),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          ImportPlayersDialog(onImportComplete: () => _loadData()),
    );
  }

  Future<void> _downloadTemplate() async {
    final template = _csvService.generateCsvTemplate();
    final fileName = 'template_jogadores.csv';

    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        const XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );

    if (location == null) return;

    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(template)),
      mimeType: 'text/csv',
      name: fileName,
    );

    await file.saveTo(location.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template salvo em ${location.path}')),
    );
  }

  void _openNewPlayerPage({Player? player}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NewPlayerPage(player: player)),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _confirmDeletePlayer(Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Deseja realmente excluir o jogador "${player.fullName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _playerService.deletePlayer(player.id!);
              _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jogador excluído com sucesso')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _showFilters ? 280 : 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Limpar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Position?>(
                        value: _selectedPosition,
                        decoration: const InputDecoration(
                          labelText: 'Posição',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas'),
                          ),
                          ...Position.values.map(
                            (p) =>
                                DropdownMenuItem(value: p, child: Text(p.name)),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedPosition = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<PlayerStatus?>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...PlayerStatus.values.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name.toUpperCase()),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedClubId,
                        decoration: const InputDecoration(
                          labelText: 'Clube',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._clubs.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedClubId = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedCountryId,
                        decoration: const InputDecoration(
                          labelText: 'País',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._countries.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedCountryId = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _minOverall?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Overall mín',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) =>
                                  _minOverall = int.tryParse(value),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('-'),
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: _maxOverall?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Overall máx',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) =>
                                  _maxOverall = int.tryParse(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.search),
                      label: const Text('Aplicar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderEditor(
            title: "Jogadores",
            isGridView: isGridView,
            onToggleView: (grid) => setState(() => isGridView = grid),
            btnSave: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.upload_file,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'CSV',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
                      ],
                    ),
                  ),
                  tooltip: 'CSV',
                  onSelected: (value) {
                    if (value == 'import') {
                      _showImportDialog();
                    } else if (value == 'export') {
                      _exportPlayersCsv();
                    } else if (value == 'template') {
                      _downloadTemplate();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [
                          Icon(Icons.file_upload, size: 20),
                          SizedBox(width: 8),
                          Text('Importar CSV'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.file_download, size: 20),
                          SizedBox(width: 8),
                          Text('Exportar CSV'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'template',
                      child: Row(
                        children: [
                          Icon(Icons.description, size: 20),
                          SizedBox(width: 8),
                          Text('Baixar Template'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openNewPlayerPage(),
                  icon: const Icon(Icons.add),
                  label: const Text("Novo jogador"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar jogadores...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: _showFilters ? Colors.blue[700] : Colors.grey[600],
                  ),
                  tooltip: 'Filtros',
                  style: IconButton.styleFrom(
                    backgroundColor: _showFilters ? Colors.blue[50] : null,
                  ),
                ),
              ],
            ),
          ),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _players.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum jogador encontrado',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : isGridView
                ? PlayerGridView(
                    players: _players,
                    onEdit: (p) => _openNewPlayerPage(player: p),
                    onDelete: _confirmDeletePlayer,
                  )
                : PlayerListView(
                    players: _players,
                    onEdit: (p) => _openNewPlayerPage(player: p),
                    onDelete: _confirmDeletePlayer,
                  ),
          ),
        ],
      ),
    );
  }
}
