import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback aoLogar;
  const LoginScreen({super.key, required this.aoLogar});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login - Guia Carapicuíba")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usuarioController,
              decoration: InputDecoration(labelText: "Usuário"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: senhaController,
              decoration: InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                widget.aoLogar();
              },
              child: Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }
}
