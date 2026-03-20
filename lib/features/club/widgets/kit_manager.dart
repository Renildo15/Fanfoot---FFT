import 'package:fanfoot/core/enums/kit.dart';
import 'package:fanfoot/core/models/kit.dart';
import 'package:fanfoot/core/services/kit_service.dart';
import 'package:fanfoot/features/club/widgets/kit_editor_dialog.dart';
import 'package:fanfoot/features/club/widgets/kit_preview.dart';
import 'package:flutter/material.dart';

class KitManager extends StatefulWidget {
  final int clubId;
  final int seasonYear;
  final String clubName;

  const KitManager({
    super.key,
    required this.clubId,
    required this.seasonYear,
    required this.clubName,
  });

  @override
  State<KitManager> createState() => _KitManagerState();
}

class _KitManagerState extends State<KitManager> {
  final _kitService = KitService();
  List<Kit> _kits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKits();
  }

  Future<void> _loadKits() async {
    setState(() => _isLoading = true);
    final kits = await _kitService.getKitsByClubAndSeason(
      widget.clubId,
      widget.seasonYear,
    );
    setState(() {
      _kits = kits;
      _isLoading = false;
    });
  }

  Future<void> _addKit() async {
    final kit = await showDialog<Kit>(
      context: context,
      builder: (context) =>
          KitEditorDialog(clubId: widget.clubId, seasonYear: widget.seasonYear),
    );

    if (kit != null) {
      await _kitService.insertKit(kit);
      _loadKits();
    }
  }

  Future<void> _editKit(Kit kit) async {
    final updatedKit = await showDialog<Kit>(
      context: context,
      builder: (context) => KitEditorDialog(
        clubId: widget.clubId,
        seasonYear: widget.seasonYear,
        existingKit: kit,
      ),
    );

    if (updatedKit != null) {
      await _kitService.updateKit(updatedKit);
      _loadKits();
    }
  }

  Future<void> _deleteKit(Kit kit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Uniforme'),
        content: Text(
          'Deseja excluir o uniforme ${_getKitTypeName(kit.type)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _kitService.deleteKit(kit.id!);
      _loadKits();
    }
  }

  String _getKitTypeName(KitType type) {
    switch (type) {
      case KitType.home:
        return 'Casa';
      case KitType.away:
        return 'Visitante';
      case KitType.third:
        return 'Terceiro';
      case KitType.goalkeeper:
        return 'Goleiro';
    }
  }

  IconData _getKitIcon(KitType type) {
    switch (type) {
      case KitType.home:
        return Icons.home;
      case KitType.away:
        return Icons.directions_car;
      case KitType.third:
        return Icons.looks_3;
      case KitType.goalkeeper:
        return Icons.sports_handball;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checkroom, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Uniformes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addKit,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_kits.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.checkroom, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhum uniforme cadastrado',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _addKit,
                      icon: const Icon(Icons.add),
                      label: const Text('Criar uniforme'),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kits.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final kit = _kits[index];
                    return _KitCard(
                      kit: kit,
                      onEdit: () => _editKit(kit),
                      onDelete: () => _deleteKit(kit),
                      onSetDefault: () async {
                        await _kitService.setDefaultKit(
                          kit.id!,
                          kit.clubId,
                          kit.seasonYear,
                          kit.type,
                        );
                        _loadKits();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KitCard extends StatelessWidget {
  final Kit kit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _KitCard({
    required this.kit,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  String _getKitTypeName(KitType type) {
    switch (type) {
      case KitType.home:
        return 'Casa';
      case KitType.away:
        return 'Visitante';
      case KitType.third:
        return 'Terceiro';
      case KitType.goalkeeper:
        return 'Goleiro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (kit.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Padrão',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (kit.isDefault) const SizedBox(width: 4),
                    Text(
                      _getKitTypeName(kit.type),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (context) => [
                    if (!kit.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 18),
                            SizedBox(width: 8),
                            Text('Definir como padrão'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'default') onSetDefault();
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: KitPreviewWithLabel(
                primaryColor: kit.primaryColor,
                secondaryColor: kit.secondaryColor,
                pattern: kit.pattern,
                playerNumber: kit.playerNumber,
                width: 100,
                height: 130,
                label: _getKitTypeName(kit.type),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
