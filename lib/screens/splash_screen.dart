import 'package:flutter/material.dart';
import 'package:projeto_retorno/screens/home_screen.dart';
import 'package:projeto_retorno/screens/login_screen.dart';
import 'package:projeto_retorno/themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ThemeMode temaAtual = ThemeMode.light;
  bool logado = false;

  void alterarTema() {
    setState(() {
      temaAtual = temaAtual == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void fazerLogin() {
    setState(() {
      logado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: temaAtual,
      home: logado
          ? HomeScreen(alterarTema: alterarTema) // se logado for true
          : LoginScreen(aoLogar: fazerLogin), // se logado for false
    );
  }
}
