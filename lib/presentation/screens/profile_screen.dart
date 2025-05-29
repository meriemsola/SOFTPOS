import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Center(
        child: Text(
          "Page Profil (en construction)",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
