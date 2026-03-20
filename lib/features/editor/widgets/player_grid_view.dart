import 'package:fanfoot/core/models/player.dart';
import 'package:fanfoot/features/editor/widgets/player_grid_view_item.dart';
import 'package:flutter/material.dart';

class PlayerGridView extends StatelessWidget {
  final List<Player> players;
  final Function(Player)? onEdit;
  final Function(Player)? onDelete;

  const PlayerGridView({
    super.key,
    required this.players,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: players.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final player = players[index];
          return PlayerGridViewItem(
            player: player,
            onEdit: onEdit != null ? () => onEdit!(player) : null,
            onDelete: onDelete != null ? () => onDelete!(player) : null,
          );
        },
      ),
    );
  }
}
