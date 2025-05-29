import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hce_emv/app.dart';
import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
// Page de validation de la carte
// Page principale après validation
// Page d'accueil
// Page des cartes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleFonts.pendingFonts([GoogleFonts.poppins(), GoogleFonts.inter()]);

  runApp(
    ProviderScope(
      overrides: [
        // Initialize auth state eagerly
        authStateProvider.overrideWith(() => AuthState()),
      ],
      child: const MyApp(),
    ),
  );
}

// void main() {
//   runApp(CardValidationApp());
// }

// class CardValidationApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'HB Technologies Pay',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         fontFamily: null,
//         textTheme: const TextTheme().apply(
//           fontFamily: null,
//           bodyColor: Colors.black,
//           displayColor: Colors.black,
//         ),
//       ),
//       home: SignInScreen(), // Démarre avec la page de validation de la carte
//       debugShowCheckedModeBanner: false,

//       // Définition des routes
//       routes: {
//         '/main_navigation': (context) => MainNavigationScreen(),
//         '/card_validation': (context) => CardValidationScreen(),
//         '/my_cards': (context) => const MyCardsScreen(),
//         '/home_page': (context) => const MyHomePage(),
//       },
//     );
//   }
// }
