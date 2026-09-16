import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/print/print_home_screen.dart';

void main() {
  runApp(const ProviderScope(child: LalithaApp()));
}

class LalithaApp extends StatelessWidget {
  const LalithaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lalitha Naturals',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const PrintHomeScreen(),
    );
  }
}
