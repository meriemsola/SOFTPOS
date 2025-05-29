import 'package:flutter/material.dart';
import 'package:hce_emv/presentation/screens/my_cards_screen.dart'; // Assurez-vous d'avoir l'import pour My Cards
import 'package:hce_emv/presentation/screens/profile_screen.dart'; // Import pour Profile Screen
import 'package:hce_emv/presentation/screens/history_screen.dart'; // Import pour History Screen
import 'package:hce_emv/presentation/screens/card_result_screen.dart'; // Assurez-vous d'avoir la Home screen

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // Index de la page sélectionnée

  final List<Widget> _pages = [
    const MyHomePage(), // Page d'accueil
    const HistoryScreen(), // Page Historique (à créer)
    const MyCardsScreen(), // Page Mes cartes
    const ProfileScreen(), // Page Profil (à créer)
  ];

  // Méthode de changement de page
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index; // Mise à jour de la page sélectionnée
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affiche la page selon l'index
      bottomNavigationBar: BottomAppBar(
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
              _buildTabItem(
                icon: Icons.credit_card,
                label: 'My Cards',
                index: 2,
              ),
              _buildTabItem(icon: Icons.person, label: 'Profile', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour chaque élément de la barre de navigation
  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected =
        _currentIndex == index; // Vérifie si l'icône est sélectionnée
    final color =
        isSelected
            ? Colors.indigo
            : Colors.grey[700]; // Couleur de l'icône sélectionnée

    return GestureDetector(
      onTap: () => _onTabSelected(index), // Change la page au clic
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
