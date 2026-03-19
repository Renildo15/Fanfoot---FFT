import 'package:fanfoot/features/editor/screens/club_screen.dart';
import 'package:fanfoot/features/editor/widgets/siderbar.dart';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  Widget _currentScreen = ClubScreen();
  int _selectedIndex = 0;
  void setScreen(int index, Widget screen) {
    setState(() {
      _selectedIndex = index;
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 28),
            const SizedBox(width: 12),
            const Text('Editor'),
          ],
        ),
        elevation: 2,
      ),
      body: Row(
        children: [
          Siderbar(
            selectedIndex: _selectedIndex,
            onSelect: (index, screen) => setScreen(index, screen),
          ),
          Container(width: 1, color: Colors.grey[300]),
          Expanded(child: _currentScreen),
        ],
      ),
    );
  }
}
