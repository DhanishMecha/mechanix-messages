import 'package:flutter/material.dart';

void main() {
  runApp(const MechanixMessageApp());
}

class MechanixMessageApp extends StatelessWidget {
  const MechanixMessageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mechanix Message App',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: const Text('Mechanix Message App')),
    );
  }
}
