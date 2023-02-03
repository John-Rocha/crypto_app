import 'package:crypo_app/pages/home_page.dart';
import 'package:crypo_app/ui/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto App',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
