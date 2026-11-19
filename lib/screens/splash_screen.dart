import 'package:flutter/material.dart';
import 'package:projeto_retorno/controllers/acesso_controller.dart';
import 'package:projeto_retorno/models/usuario.dart';
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
  final acesso = AcessoController();
  Usuario? usuario;

  void alterarTema() {
    setState(() {
      temaAtual = temaAtual == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void fazerLogin(Usuario novoUsuario) {
    setState(() => usuario = novoUsuario);
  }

  Future<void> sair() async {
    await acesso.sair();
    if (mounted) setState(() => usuario = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: temaAtual,
      home: usuario == null
          ? LoginScreen(acesso: acesso, aoLogar: fazerLogin)
          : HomeScreen(
              api: acesso.api,
              usuario: usuario!,
              alterarTema: alterarTema,
              sair: sair,
            ),
    );
  }
}
