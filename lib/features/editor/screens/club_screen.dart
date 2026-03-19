import 'dart:convert';
import 'dart:typed_data';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/services/club_csv_service.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/features/club/new_club_page.dart';
import 'package:fanfoot/features/club/widgets/import_clubs_dialog.dart';
import 'package:fanfoot/features/editor/widgets/club_grid_view.dart';
import 'package:fanfoot/features/editor/widgets/club_list_view.dart';
import 'package:fanfoot/features/editor/widgets/header_editor.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  bool isGridView = false;
  final _csvService = ClubCsvService();

  void toggleView(bool grid) {
    setState(() {
      isGridView = grid;
    });
  }

  Future<void> _exportClubsCsv() async {
    final clubs = await ClubService().getAllClubs();
    if (clubs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum clube para exportar')),
      );
      return;
    }

    final csvContent = _csvService.exportClubsToCsv(clubs);
    final fileName =
        'clubes_export_${DateTime.now().millisecondsSinceEpoch}.csv';

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
      SnackBar(content: Text('Clubes exportados para ${location.path}')),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          ImportClubsDialog(onImportComplete: () => setState(() {})),
    );
  }

  Future<void> _downloadTemplate() async {
    final template = _csvService.generateCsvTemplate();
    final fileName = 'template_clubes.csv';

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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderEditor(
            title: "Clubes",
            isGridView: isGridView,
            onToggleView: toggleView,
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
                      _exportClubsCsv();
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewClubPage(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Novo clube"),
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
          Expanded(
            child: FutureBuilder<List<Club>>(
              future: ClubService().getAllClubs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar clubes: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum clube encontrado'));
                }

                final clubs = snapshot.data!;

                return isGridView
                    ? ClubGridView(clubs: clubs)
                    : ClubListView(clubs: clubs);
              },
            ),
          ),
        ],
      ),
    );
  }
}
