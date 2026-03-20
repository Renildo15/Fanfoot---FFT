import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/features/editor/widgets/club_list_view_item.dart';
import 'package:flutter/material.dart';

class ClubListView extends StatelessWidget {
  final List<Club> clubs;
  final Function(Club)? onEdit;
  final Function(Club)? onDelete;

  const ClubListView({
    super.key,
    required this.clubs,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemBuilder: (context, index) {
          final club = clubs[index];
          return ClubListViewItem(
            club: club,
            onEdit: onEdit != null ? () => onEdit!(club) : null,
            onDelete: onDelete != null ? () => onDelete!(club) : null,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: clubs.length,
      ),
    );
  }
}
