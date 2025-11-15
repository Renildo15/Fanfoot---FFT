import 'package:flutter/material.dart';

class HeaderEditor extends StatelessWidget {
  final String title;
  final bool isGridView;
  final Function(bool) onToggleView;
  final Widget btnSave;
  const HeaderEditor({
    super.key,
    required this.title,
    required this.isGridView,
    required this.onToggleView,
    required this.btnSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              btnSave,
              const SizedBox(width: 8),

              IconButton(
                onPressed: () => onToggleView(false),
                icon: Icon(
                  Icons.view_list,
                  color: isGridView ? Colors.grey : Colors.black,
                ),
                tooltip: 'Modo lista',
              ),
              IconButton(
                onPressed: () => onToggleView(true),
                icon: Icon(
                  Icons.grid_view,
                  color: isGridView ? Colors.black : Colors.grey,
                ),
                tooltip: 'Modo grade',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
