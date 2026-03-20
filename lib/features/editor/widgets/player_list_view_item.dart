import 'package:fanfoot/core/enums/player.dart';
import 'package:fanfoot/core/models/country.dart';
import 'package:fanfoot/core/models/player.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:flutter/material.dart';

class PlayerListViewItem extends StatefulWidget {
  final Player player;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlayerListViewItem({
    super.key,
    required this.player,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PlayerListViewItem> createState() => _PlayerListViewItemState();
}

class _PlayerListViewItemState extends State<PlayerListViewItem> {
  final _countryService = CountryService();
  final _clubService = ClubService();
  Country? _country;
  String? _clubName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (widget.player.countryId != null) {
        final country = await _countryService.getCountry(
          widget.player.countryId!,
        );
        if (mounted) setState(() => _country = country);
      }
      if (widget.player.currentClubId != null) {
        final club = await _clubService.getClub(widget.player.currentClubId!);
        if (mounted) setState(() => _clubName = club?.name);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getPositionColor(
                  widget.player.position,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.player.position.name,
                  style: TextStyle(
                    color: _getPositionColor(widget.player.position),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.player.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.player.surname != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '"${widget.player.surname}"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            widget.player.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.player.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(widget.player.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (_country != null)
                        Image.network(
                          _country!.flag,
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.flag, size: 20),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.player.age} anos',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (_clubName != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.shield, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _clubName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _StatBadge(
                      label: 'OVR',
                      value: widget.player.overall.toString(),
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    _StatBadge(
                      label: 'POT',
                      value: widget.player.potential.toString(),
                      color: Colors.teal,
                    ),
                  ],
                ),
                if (widget.player.shirtNumber > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '#${widget.player.shirtNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: "Editar",
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "Excluir",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
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
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
