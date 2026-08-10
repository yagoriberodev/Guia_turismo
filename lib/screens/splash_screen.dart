import 'package:flutter/material.dart';
import 'package:projeto_retorno/screens/home_screen.dart';
import 'package:projeto_retorno/themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ThemeMode temaAtual = ThemeMode.light;

  void alterarTema(){
    setState(() {
      temaAtual = temaAtual == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: HomeScreen(),//CamelCase
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode:  temaAtual,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(alterarTema: alterarTema),
        // 'lugares': (context) = LugaresScreen(),
      },    
    );
  }
}