import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback alterarTema;
  const HomeScreen({super.key, required this.alterarTema});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Osasco"),
        actions: [
          IconButton(
          onPressed: () => widget.alterarTema(),
          icon:Icon(Icons.dark_mode))
        ],//botão no canto superior direito do app
      ),
      body: Column(
        children: [
          Text("Bem-vindo a OSASCO"),
          ElevatedButton(
            onPressed: (){
              debugPrint("Botão clicado");
            },
            child: Text("Clique em mim"),
          ),
        ],
      ),
      // drawer: ,
      // endDrawer: ,
      // floatingActionButton: ,
      // bottomNavigationBar: ,

    );
  }
}