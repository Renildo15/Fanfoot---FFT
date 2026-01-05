import 'package:fanfoot/features/competition/new_competition_page.dart';
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
            btnSave: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewCompetitionPage(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Nova competição"),
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
          ),
        ],
      ),
    );
  }
}
