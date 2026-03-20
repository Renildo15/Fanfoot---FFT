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
      width: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header da sidebar
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1, thickness: 1),

          // Lista de botões
          Expanded(
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
          ),
        ],
      ),
    );
  }
}
