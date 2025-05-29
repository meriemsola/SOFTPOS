import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique")),
      body: Center(
        child: Text(
          "Page Historique (en construction)",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
