import 'package:flutter/material.dart';

class SiderbarButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;

  const SiderbarButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = selected ? Colors.green[900]! : Colors.green[700]!;
    final Color fg = Colors.white;
    final double elevation = selected ? 8 : 4;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: fg),
      label: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerLeft,
        elevation: elevation,
        shadowColor: Colors.black45,
      ),
    );
  }
}
