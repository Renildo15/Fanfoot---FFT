import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerField extends StatelessWidget {
  final Color color;
  final String label;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerField({
    super.key,
    required this.color,
    required this.label,
    required this.onColorChanged,
  });

  void _openPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(pickerColor: color, onColorChanged: onColorChanged),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Selecionar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _openPicker(context),
          child: Text(label),
        ),
      ],
    );
  }
}
