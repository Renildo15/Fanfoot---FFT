import 'package:fanfoot/core/enums/player.dart';
import 'package:fanfoot/core/models/player.dart';
import 'package:flutter/material.dart';

class PlayerGridViewItem extends StatelessWidget {
  final Player player;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlayerGridViewItem({
    super.key,
    required this.player,
    this.onEdit,
    this.onDelete,
  });

  Color _getPositionColor(Position position) {
    switch (position) {
      case Position.GK:
        return Colors.yellow[700]!;
      case Position.RB:
      case Position.LB:
      case Position.CB:
      case Position.RWB:
      case Position.LWB:
        return Colors.blue[700]!;
      case Position.CDM:
      case Position.CM:
      case Position.CAM:
        return Colors.green[700]!;
      case Position.RM:
      case Position.LM:
      case Position.RW:
      case Position.LW:
        return Colors.orange[700]!;
      case Position.CF:
      case Position.ST:
        return Colors.red[700]!;
    }
  }

  Color _getStatusColor(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.active:
        return Colors.green;
      case PlayerStatus.injured:
        return Colors.orange;
      case PlayerStatus.suspended:
        return Colors.red;
      case PlayerStatus.academy:
        return Colors.blue;
      case PlayerStatus.retired:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getPositionColor(player.position).withValues(alpha: 0.8),
                    _getPositionColor(player.position).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      player.position.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                      ),
                    ),
                  ),
                  if (player.shirtNumber > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${player.shirtNumber}',
                          style: TextStyle(
                            color: _getPositionColor(player.position),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(player.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        player.status.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (player.surname != null)
                        Text(
                          '"${player.surname}"',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatChip(
                        label: 'OVR',
                        value: player.overall,
                        color: Colors.purple,
                      ),
                      _StatChip(
                        label: 'POT',
                        value: player.potential,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  tooltip: "Editar",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  tooltip: "Excluir",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
