import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/features/editor/widgets/club_grid_view_item.dart';
import 'package:flutter/material.dart';

class ClubGridView extends StatelessWidget {
  final List<Club> clubs;
  const ClubGridView({super.key, required this.clubs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: clubs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 2 cards por linha
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 3, // largura / altura do card
        ),
        itemBuilder: (context, index) {
          final club = clubs[index];
          return ClubGridViewItem(club: club);
        },
      ),
    );
  }
}
