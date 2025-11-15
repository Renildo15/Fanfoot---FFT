import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/features/club/new_club_page.dart';
import 'package:fanfoot/features/editor/widgets/club_grid_view.dart';
import 'package:fanfoot/features/editor/widgets/club_list_view.dart';
import 'package:fanfoot/features/editor/widgets/header_editor.dart';
import 'package:flutter/material.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
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
            title: "Clubes",
            isGridView: isGridView,
            onToggleView: toggleView,
            btnSave: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewClubPage()),
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
