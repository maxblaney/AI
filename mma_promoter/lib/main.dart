import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/screens/home_shell.dart';
import 'presentation/state/game_controller.dart';

void main() {
  runApp(const MmaPromoterApp());
}

class MmaPromoterApp extends StatelessWidget {
  const MmaPromoterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The web build has no `dart:io`/SQLite backend, so it runs on a
    // volatile in-memory repository set instead (see GameController.inMemory
    // and lib/data/db/connection_web.dart). Native builds persist for real.
    return ChangeNotifierProvider(
      create: (_) =>
          (kIsWeb ? GameController.inMemory() : GameController())..init(),
      child: MaterialApp(
        title: 'MMA Promoter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFB4222B),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
