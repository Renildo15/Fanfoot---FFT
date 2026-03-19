import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  final File? crestFile;
  final Function(File?)? onImageSelected;
  const ImagePreview({super.key, this.crestFile, this.onImageSelected});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final selectedFile = File(file.path);
      // Notificar o widget pai sobre a seleção (ele atualizará o estado)
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(selectedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFile = widget.crestFile;

    return Column(
      children: [
        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[200]!, Colors.grey[300]!],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: currentFile != null
                    ? const Color(0xFF2E7D32)
                    : Colors.grey[400]!,
                width: currentFile != null ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: currentFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.file(currentFile, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicionar\nEmblema',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: pickImage,
          icon: const Icon(Icons.upload, size: 18),
          label: const Text("Selecionar emblema"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
