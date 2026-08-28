import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/screens/home_shell.dart';
import 'presentation/state/game_controller.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const MmaPromoterApp());
}

class MmaPromoterApp extends StatelessWidget {
  const MmaPromoterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Both native and web persist: native goes through on-device SQLite,
    // web runs the same schema on sqlite3-wasm with the database file
    // stored by the browser (see lib/data/db/connection_web.dart).
    // GameController.inMemory() still exists for tests.
    return ChangeNotifierProvider(
      create: (_) => GameController()..init(),
      child: MaterialApp(
        title: 'MMA Promoter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const HomeShell(),
      ),
    );
  }
}
