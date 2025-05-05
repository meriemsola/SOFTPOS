import 'package:flutter/material.dart';
import 'package:hce_emv/presentation/card_input_screen.dart'; // 👈 adapte le chemin si besoin

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HCE EMV Card Emulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CardInputScreen(), // 👈 Ici on lance directement ta page !
    );
  }
}
