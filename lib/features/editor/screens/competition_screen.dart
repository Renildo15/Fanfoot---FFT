import 'package:fanfoot/features/editor/widgets/header_editor.dart';
import 'package:flutter/material.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  bool isGridView = false;

  void toggleView(bool grid) {
    setState(() {
      isGridView = grid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderEditor(
            title: "Competições",
            isGridView: true,
            onToggleView: toggleView,
          ),
        ],
      ),
    );
  }
}
