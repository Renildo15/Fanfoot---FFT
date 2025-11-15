import 'package:fanfoot/features/editor/widgets/siderbar_button.dart';
import 'package:flutter/material.dart';
import 'package:fanfoot/routes/routes.dart';

class Siderbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int, Widget) onSelect;

  const Siderbar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.grey[200],
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final item = routes[index];
          return SiderbarButton(
            title: item["title"] as String,
            icon: item["icon"] as IconData,
            selected: selectedIndex == index,
            onPressed: () {
              onSelect(index, item["screen"] as Widget);
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}
