import 'package:flutter/material.dart';

class SiderbarButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const SiderbarButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerLeft,
        elevation: 4,
        shadowColor: Colors.black45,
      ),
    );
  }
}
