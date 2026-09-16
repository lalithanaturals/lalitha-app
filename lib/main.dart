import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/print/price_tag/price_tag_screen.dart';

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
      home: const PriceTagScreen(),
    );
  }
}
