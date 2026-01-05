import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  File? crestFile;
  ImagePreview({super.key, this.crestFile});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  Future<void> pickImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        widget.crestFile = File(file.path);
      });
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickImage,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            clipBehavior: Clip.hardEdge,
            child: widget.crestFile != null
                ? Image.file(widget.crestFile!, fit: BoxFit.cover)
                : const Icon(
                    Icons.shield_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.upload),
            label: const Text("Selecionar emblema"),
          ),
        ],
      ),
    );
  }
}
