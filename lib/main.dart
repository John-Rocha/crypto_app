import 'package:crypo_app/configs/app_settings.dart';
import 'package:crypo_app/repositories/conta_repository.dart';
import 'package:crypo_app/repositories/favoritas_repository.dart';
import 'package:crypo_app/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'configs/hive_config.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContaRepository()),
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => FavoritasRepository()),
      ],
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
