import 'package:fanfoot/core/models/player.dart';
import 'package:fanfoot/features/editor/widgets/player_list_view_item.dart';
import 'package:flutter/material.dart';

class PlayerListView extends StatelessWidget {
  final List<Player> players;
  final Function(Player)? onEdit;
  final Function(Player)? onDelete;

  const PlayerListView({
    super.key,
    required this.players,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemBuilder: (context, index) {
          final player = players[index];
          return PlayerListViewItem(
            player: player,
            onEdit: onEdit != null ? () => onEdit!(player) : null,
            onDelete: onDelete != null ? () => onDelete!(player) : null,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: players.length,
      ),
    );
  }
}
