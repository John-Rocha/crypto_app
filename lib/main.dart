import 'package:crypo_app/configs/app_settings.dart';
import 'package:crypo_app/repositories/conta_repository.dart';
import 'package:crypo_app/repositories/favoritas_repository.dart';
import 'package:crypo_app/repositories/moeda_repository.dart';
import 'package:crypo_app/services/auth_service.dart';
import 'package:crypo_app/ui/app_theme.dart';
import 'package:crypo_app/widgets/auth_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'configs/hive_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => MoedaRepository()),
        ChangeNotifierProvider(
          create: (context) => ContaRepository(
            moedas: context.read<MoedaRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(
          create: (context) => FavoritasRepository(
            auth: context.read<AuthService>(),
            moedas: context.read<MoedaRepository>(),
          ),
        ),
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
      home: const AuthCheck(),
    );
  }
}
