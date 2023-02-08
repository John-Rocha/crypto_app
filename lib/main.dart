import 'package:crypo_app/repositories/favoritas_repository.dart';
import 'package:crypo_app/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritasRepository(),
      child: const MyApp(),
    ),
  );
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
