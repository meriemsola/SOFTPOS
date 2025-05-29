import 'package:flutter/material.dart';

class NavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const NavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabItem(icon: Icons.home, label: 'Home', index: 0),
            _buildTabItem(icon: Icons.history, label: 'History', index: 1),
            _buildTabItem(icon: Icons.credit_card, label: 'My Cards', index: 2),
            _buildTabItem(icon: Icons.person, label: 'Profile', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? Colors.indigo : Colors.grey[700];

    return GestureDetector(
      onTap:
          () => onTabSelected(
            index,
          ), // Appelle onTabSelected pour changer l'index
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
