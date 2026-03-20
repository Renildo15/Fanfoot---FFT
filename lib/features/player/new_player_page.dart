import 'package:fanfoot/core/enums/player.dart';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/models/player.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/core/services/player_service.dart';
import 'package:fanfoot/features/widgets/select_country.dart';
import 'package:flutter/material.dart';

class NewPlayerPage extends StatefulWidget {
  final Player? player;

  const NewPlayerPage({super.key, this.player});

  @override
  State<NewPlayerPage> createState() => _NewPlayerPageState();
}

class _NewPlayerPageState extends State<NewPlayerPage> {
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String? _surname;
  int _age = 16;
  Position _position = Position.CM;
  Position? _secondaryPosition;
  PlayerPreferredFoot _preferredFoot = PlayerPreferredFoot.R;
  int _heightCm = 170;
  double _weightKg = 70.0;
  int _overall = 50;
  int _potential = 50;
  int _fitness = 100;
  PlayerStatus _status = PlayerStatus.active;
  int _shirtNumber = 0;
  double _salaryWeekly = 0.0;
  int _contractUntil = DateTime.now().year + 1;
  int? _currentClubId;
  int? _countryId;

  List<Country> _countries = [];
  List<Club> _clubs = [];
  bool _isLoadingData = true;

  final _playerService = PlayerService();
  final _countryService = CountryService();
  final _clubService = ClubService();

  bool get isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _loadPlayerData(widget.player!);
    }
    _loadData();
  }

  void _loadPlayerData(Player player) {
    _fullName = player.fullName;
    _surname = player.surname;
    _age = player.age;
    _position = player.position;
    _secondaryPosition = player.secondaryPosition;
    _preferredFoot = player.preferredFoot;
    _heightCm = player.heightCm;
    _weightKg = player.weightKg;
    _overall = player.overall;
    _potential = player.potential;
    _fitness = player.fitness;
    _status = player.status;
    _shirtNumber = player.shirtNumber;
    _salaryWeekly = player.salaryWeekly;
    _contractUntil = player.contractUntil;
    _currentClubId = player.currentClubId;
    _countryId = player.countryId;
  }

  Future<void> _loadData() async {
    final countries = await _countryService.getAllCountries();
    final clubs = await _clubService.getAllClubs();

    setState(() {
      _countries = countries;
      _clubs = clubs;
      _isLoadingData = false;
    });
  }

  Future<void> _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final player = Player(
        id: widget.player?.id,
        fullName: _fullName,
        surname: _surname,
        age: _age,
        position: _position,
        secondaryPosition: _secondaryPosition,
        preferredFoot: _preferredFoot,
        heightCm: _heightCm,
        weightKg: _weightKg,
        overall: _overall,
        potential: _potential,
        fitness: _fitness,
        status: _status,
        shirtNumber: _shirtNumber,
        salaryWeekly: _salaryWeekly,
        contractUntil: _contractUntil,
        currentClubId: _currentClubId,
        countryId: _countryId,
      );

      try {
        if (isEditing) {
          await _playerService.updatePlayer(player);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jogador atualizado com sucesso!")),
          );
        } else {
          await _playerService.insertPlayer(player);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jogador salvo com sucesso!")),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar o jogador: $e")));
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField({
    required String label,
    required int value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    String? formatValue,
    required Color color,
  }) {
    final displayValue = formatValue ?? value.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.3),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min,
              max: max,
              divisions: divisions,
              label: displayValue,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 28),
            const SizedBox(width: 12),
            Text(isEditing ? "Editar Jogador" : "Novo Jogador"),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF5F5F5), Colors.grey[100]!],
          ),
        ),
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Informações Pessoais',
                        icon: Icons.person_outline,
                        color: Colors.blue[700]!,
                        children: [
                          TextFormField(
                            initialValue: _fullName,
                            decoration: InputDecoration(
                              labelText: 'Nome completo',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSaved: (newValue) => _fullName = newValue ?? '',
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Obrigatório'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _surname,
                                  decoration: InputDecoration(
                                    labelText: 'Apelido',
                                    prefixIcon: const Icon(Icons.face),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onSaved: (newValue) => _surname = newValue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _shirtNumber > 0
                                      ? _shirtNumber.toString()
                                      : '',
                                  decoration: InputDecoration(
                                    labelText: 'Número da camisa',
                                    prefixIcon: const Icon(Icons.tag),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSaved: (newValue) => _shirtNumber =
                                      int.tryParse(newValue ?? '') ?? 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<PlayerStatus>(
                                  value: _status,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    prefixIcon: const Icon(Icons.info),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: PlayerStatus.values
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s.name.toUpperCase()),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => _status = value!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SelectCountry(
                                  countries: _countries,
                                  countryId: _countryId,
                                  isLoadingCountries: false,
                                  onChanged: (value) {
                                    setState(() => _countryId = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Posição',
                        icon: Icons.sports_soccer,
                        color: Colors.green[700]!,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<Position>(
                                  value: _position,
                                  decoration: InputDecoration(
                                    labelText: 'Posição principal',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: Position.values
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(p.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => _position = value!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<Position?>(
                                  value: _secondaryPosition,
                                  decoration: InputDecoration(
                                    labelText: 'Posição secundária',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('Nenhuma'),
                                    ),
                                    ...Position.values.map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p.name),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _secondaryPosition = value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<PlayerPreferredFoot>(
                            value: _preferredFoot,
                            decoration: InputDecoration(
                              labelText: 'Pé preferencial',
                              prefixIcon: const Icon(Icons.directions_walk),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: PlayerPreferredFoot.values
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(_getFootLabel(f)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _preferredFoot = value!),
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Atributos Físicos',
                        icon: Icons.fitness_center,
                        color: Colors.orange[700]!,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _age.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Idade',
                                    prefixIcon: const Icon(Icons.cake),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSaved: (newValue) =>
                                      _age = int.tryParse(newValue ?? '') ?? 16,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _heightCm.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Altura (cm)',
                                    prefixIcon: const Icon(Icons.height),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSaved: (newValue) => _heightCm =
                                      int.tryParse(newValue ?? '') ?? 170,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _weightKg.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Peso (kg)',
                                    prefixIcon: const Icon(
                                      Icons.monitor_weight,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  onSaved: (newValue) => _weightKg =
                                      double.tryParse(newValue ?? '') ?? 70.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Habilidades',
                        icon: Icons.star,
                        color: Colors.purple[700]!,
                        children: [
                          _buildSliderField(
                            label: 'Overall',
                            value: _overall,
                            min: 1,
                            max: 99,
                            divisions: 98,
                            onChanged: (value) =>
                                setState(() => _overall = value.toInt()),
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 16),
                          _buildSliderField(
                            label: 'Potencial',
                            value: _potential,
                            min: 1,
                            max: 99,
                            divisions: 98,
                            onChanged: (value) =>
                                setState(() => _potential = value.toInt()),
                            color: Colors.teal,
                          ),
                          const SizedBox(height: 16),
                          _buildSliderField(
                            label: 'Condição Física',
                            value: _fitness,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            onChanged: (value) =>
                                setState(() => _fitness = value.toInt()),
                            color: Colors.green,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Carreira',
                        icon: Icons.work_outline,
                        color: Colors.indigo[700]!,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int?>(
                                  value: _currentClubId,
                                  decoration: InputDecoration(
                                    labelText: 'Clube atual',
                                    prefixIcon: const Icon(Icons.shield),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('Sem clube'),
                                    ),
                                    ..._clubs.map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _currentClubId = value),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _contractUntil.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Contrato até',
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSaved: (newValue) => _contractUntil =
                                      int.tryParse(newValue ?? '') ??
                                      DateTime.now().year + 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSliderField(
                            label: 'Salário Semanal',
                            value: _salaryWeekly.toInt(),
                            min: 0,
                            max: 1000000,
                            divisions: 100,
                            formatValue: _formatCurrency(_salaryWeekly),
                            onChanged: (value) =>
                                setState(() => _salaryWeekly = value),
                            color: Colors.amber[700]!,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _savePlayer,
                          icon: const Icon(Icons.save, size: 24),
                          label: Text(
                            isEditing ? 'Atualizar Jogador' : 'Salvar Jogador',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _getFootLabel(PlayerPreferredFoot foot) {
    switch (foot) {
      case PlayerPreferredFoot.R:
        return 'Direito';
      case PlayerPreferredFoot.L:
        return 'Esquerdo';
      case PlayerPreferredFoot.B:
        return 'Ambidestro';
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'R\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return 'R\$${value.toInt()}';
  }
}
