import 'dart:io';
import 'package:fanfoot/db/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ConfigsScreen extends StatefulWidget {
  const ConfigsScreen({super.key});

  @override
  State<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends State<ConfigsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isClearing = false;
  Map<String, int> _databaseStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseStats();
  }

  Future<void> _loadDatabaseStats() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final stats = <String, int>{};

      stats['clubs'] =
          (await db.rawQuery('SELECT COUNT(*) as c FROM club')).first['c']
              as int;
      stats['players'] =
          (await db.rawQuery('SELECT COUNT(*) as c FROM player')).first['c']
              as int;
      stats['competitions'] =
          (await db.rawQuery(
                'SELECT COUNT(*) as c FROM competition',
              )).first['c']
              as int;
      stats['coaches'] =
          (await db.rawQuery('SELECT COUNT(*) as c FROM coach')).first['c']
              as int;
      stats['kits'] =
          (await db.rawQuery('SELECT COUNT(*) as c FROM kit')).first['c']
              as int;
      stats['gameSaves'] =
          (await db.rawQuery('SELECT COUNT(*) as c FROM game_save')).first['c']
              as int;

      setState(() {
        _databaseStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  Future<String> _getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return path.join(dbPath, 'fanfoot.db');
  }

  Future<void> _exportDatabase() async {
    setState(() => _isExporting = true);

    try {
      final dbPath = await _getDatabasePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banco de dados não encontrado')),
          );
        }
        return;
      }

      final fileName =
          'fanfoot_backup_${DateTime.now().millisecondsSinceEpoch}.db';
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Database', extensions: ['db']),
        ],
      );

      if (location == null) {
        setState(() => _isExporting = false);
        return;
      }

      await dbFile.copy(location.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup salvo em: ${location.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Backup'),
        content: const Text(
          'Isso substituirá TODOS os dados atuais. Tem certeza que deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isImporting = true);

    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Database', extensions: ['db']),
        ],
      );

      if (file == null) {
        setState(() => _isImporting = false);
        return;
      }

      final dbPath = await _getDatabasePath();
      await DatabaseHelper.instance.close();
      await File(dbPath).writeAsBytes(await file.readAsBytes());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Backup importado com sucesso! Reinicie o aplicativo.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao importar: $e')));
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Limpar Todos os Dados'),
          ],
        ),
        content: const Text(
          'Isso IRÁ EXCLUIR TODOS os dados do banco de dados (clubes, jogadores, competições, etc.).\n\nEsta ação NÃO pode ser desfeita!',
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
            child: const Text('Excluir Tudo'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final doubleConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação Final'),
        content: const Text(
          'Tem certeza ABSOLUTAMENTE certeza?\n\nDigite "SIM" para confirmar.',
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
            child: const Text('SIM, EXCLUIR'),
          ),
        ],
      ),
    );

    if (doubleConfirm != true) return;

    setState(() => _isClearing = true);

    try {
      final db = await DatabaseHelper.instance.database;

      await db.delete('player_stats_season');
      await db.delete('coach_history');
      await db.delete('kit');
      await db.delete('club_competition');
      await db.delete('player');
      await db.delete('coach');
      await db.delete('club');
      await db.delete('competition');
      await db.delete('game_save');

      await _loadDatabaseStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos os dados foram excluídos!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao limpar dados: $e')));
      }
    } finally {
      setState(() => _isClearing = false);
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
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF5F5F5), Colors.grey[100]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gerencie o banco de dados e configurações do jogo',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Banco de Dados',
                icon: Icons.storage,
                color: Colors.blue[700]!,
                children: [
                  FutureBuilder<String>(
                    future: _getDatabasePath(),
                    builder: (context, snapshot) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Local do banco de dados:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              snapshot.data ?? 'Carregando...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportDatabase,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(
                            _isExporting ? 'Exportando...' : 'Exportar Backup',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isImporting ? null : _importDatabase,
                          icon: _isImporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.upload),
                          label: Text(
                            _isImporting ? 'Importando...' : 'Importar Backup',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Estatísticas dos Dados',
                icon: Icons.analytics,
                color: Colors.purple[700]!,
                children: [
                  if (_isLoadingStats)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          'Clubes',
                          _databaseStats['clubs'] ?? 0,
                          Icons.shield,
                          Colors.blue[700]!,
                        ),
                        _buildStatCard(
                          'Jogadores',
                          _databaseStats['players'] ?? 0,
                          Icons.person,
                          Colors.green[700]!,
                        ),
                        _buildStatCard(
                          'Competições',
                          _databaseStats['competitions'] ?? 0,
                          Icons.emoji_events,
                          Colors.amber[700]!,
                        ),
                        _buildStatCard(
                          'Treinadores',
                          _databaseStats['coaches'] ?? 0,
                          Icons.sports,
                          Colors.orange[700]!,
                        ),
                        _buildStatCard(
                          'Uniformes',
                          _databaseStats['kits'] ?? 0,
                          Icons.checkroom,
                          Colors.teal[700]!,
                        ),
                        _buildStatCard(
                          'Saves',
                          _databaseStats['gameSaves'] ?? 0,
                          Icons.save,
                          Colors.indigo[700]!,
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadDatabaseStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Atualizar Estatísticas'),
                    ),
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Zona de Perigo',
                icon: Icons.warning,
                color: Colors.red[700]!,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'As ações abaixo são IRREVERSÍVEIS. Certifique-se de fazer um backup antes.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isClearing ? null : _clearAllData,
                      icon: _isClearing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.delete_forever),
                      label: Text(
                        _isClearing ? 'Limpando...' : 'Limpar Todos os Dados',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Sobre',
                icon: Icons.info,
                color: Colors.grey[700]!,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    title: const Text(
                      'Fanfoot',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Simulador de Futebol'),
                  ),
                  const Divider(),
                  _buildInfoRow('Versão', '1.0.0'),
                  _buildInfoRow('Flutter', 'Desktop'),
                  _buildInfoRow('Banco de Dados', 'SQLite'),
                  _buildInfoRow('Desenvolvedor', 'Fanfoot Team'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
