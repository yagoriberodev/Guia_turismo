import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback alterarTema;
  const HomeScreen({super.key, required this.alterarTema});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pontosTuristicos = [
    "Parque Ecológico Vila dos Remédios",
    "Igreja Matriz de Carapicuíba",
    "Aldeia de Carapicuíba (patrimônio histórico)",
    "Estádio Municipal José Liberatti",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guia de Turismo - Carapicuíba"),
        actions: [
          IconButton(
            onPressed: () => widget.alterarTema(),
            icon: Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: pontosTuristicos.length,
        itemBuilder: (context, indice) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.location_on),
              title: Text(pontosTuristicos[indice]),
            ),
          );
        },
      ),
    );
  }
}
