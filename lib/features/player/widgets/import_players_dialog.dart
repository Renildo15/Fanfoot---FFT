import 'dart:io';
import 'package:fanfoot/core/services/player_csv_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ImportPlayersDialog extends StatefulWidget {
  final VoidCallback? onImportComplete;

  const ImportPlayersDialog({super.key, this.onImportComplete});

  @override
  State<ImportPlayersDialog> createState() => _ImportPlayersDialogState();
}

class _ImportPlayersDialogState extends State<ImportPlayersDialog> {
  final _csvService = PlayerCsvService();
  bool _isLoading = false;
  PlayerImportResult? _result;

  Future<void> _selectAndImportFile() async {
    const typeGroup = XTypeGroup(label: 'CSV', extensions: ['csv']);

    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    setState(() => _isLoading = true);

    final result = await _csvService.importPlayersFromFile(File(file.path));

    setState(() {
      _isLoading = false;
      _result = result;
    });

    if (result.success > 0) {
      widget.onImportComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.upload_file, color: Colors.blue[700]),
          const SizedBox(width: 12),
          const Text('Importar Jogadores via CSV'),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Formato esperado:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _csvService.generateCsvTemplate(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_result != null) ...[
              Card(
                color: _result!.errors.isEmpty
                    ? Colors.green[50]
                    : Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _result!.errors.isEmpty
                                ? Icons.check_circle
                                : Icons.warning,
                            color: _result!.errors.isEmpty
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_result!.success} jogador(es) importado(s) com sucesso',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_result!.errors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Erros encontrados:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ..._result!.errors
                            .take(10)
                            .map(
                              (e) => Text(
                                '• $e',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        if (_result!.errors.length > 10)
                          Text(
                            '... e mais ${_result!.errors.length - 10} erro(s)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Selecione um arquivo CSV com os jogadores para importar.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _selectAndImportFile,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.file_open),
          label: const Text('Selecionar Arquivo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
