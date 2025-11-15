import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/features/editor/widgets/club_grid_view.dart';
import 'package:fanfoot/features/editor/widgets/club_list_view.dart';
import 'package:fanfoot/features/editor/widgets/header_editor.dart';
import 'package:fanfoot/features/editor/widgets/siderbar.dart';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  bool isGridView = false;

  void toggleView(bool grid) {
    setState(() {
      isGridView = grid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: Row(
        children: [
          Siderbar(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderEditor(
                  title: "Clubes",
                  isGridView: isGridView,
                  onToggleView: toggleView,
                ),
                // ⚡ FutureBuilder aqui para lidar com dados assíncronos
                Expanded(
                  child: FutureBuilder<List<Club>>(
                    future: ClubService().getAllClubs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar clubes: ${snapshot.error}',
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Nenhum clube encontrado'),
                        );
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
          ),
        ],
      ),
    );
  }
}
