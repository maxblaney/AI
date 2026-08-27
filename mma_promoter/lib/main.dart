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
    return ChangeNotifierProvider(
      create: (_) => GameController()..init(),
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
