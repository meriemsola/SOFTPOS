import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/core/routes/go_router_provider.dart';
import 'package:hce_emv/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: BotToastInit(),
      debugShowCheckedModeBanner: false,
      // navigatorObservers: [BotToastNavigatorObserver()],
      routerConfig: goRouter,
    );
  }
}

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final goRouter = ref.watch(goRouterProvider);

//     return MaterialApp(
//       themeMode: ThemeMode.system,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       builder: BotToastInit(),
//       debugShowCheckedModeBanner: false,
//       navigatorObservers: [BotToastNavigatorObserver()],
//       home: Router(
//         routerDelegate: goRouter.routerDelegate,
//         routeInformationParser: goRouter.routeInformationParser,
//         routeInformationProvider: goRouter.routeInformationProvider,
//       ),
//     );
//   }
// }
