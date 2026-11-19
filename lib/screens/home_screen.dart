import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/lugar.dart';
import '../models/usuario.dart';
import '../services/guia_api.dart';
import '../services/localizacao_service.dart';
import '../widgets/foto_perfil.dart';

class HomeScreen extends StatefulWidget {
  final GuiaApi api;
  final Usuario usuario;
  final VoidCallback alterarTema;
  final Future<void> Function() sair;

  const HomeScreen({
    super.key,
    required this.api,
    required this.usuario,
    required this.alterarTema,
    required this.sair,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _gps = LocalizacaoService();
  final _lugares = <Lugar>[];
  Position? _posicao;
  int _pagina = 1;
  bool _temMais = true;
  bool _carregando = false;
  bool _localizando = false;
  bool _saindo = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    if (_carregando || !_temMais) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final novos = await widget.api.listarLugares(_pagina);
      if (!mounted) return;
      setState(() {
        _lugares.addAll(novos);
        _pagina++;
        _temMais = novos.length == 20;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar os lugares.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _localizar() async {
    setState(() => _localizando = true);
    try {
      final posicao = await _gps.buscar();
      if (mounted) setState(() => _posicao = posicao);
    } catch (erro) {
      final texto = erro.toString();
      _avisar(
        texto.startsWith('Exception: ')
            ? texto.substring(11)
            : 'Não foi possível obter sua localização. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _localizando = false);
    }
  }

  void _avisar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  double? _distancia(Lugar lugar) {
    final posicao = _posicao;
    final latitude = lugar.latitude;
    final longitude = lugar.longitude;
    if (posicao == null || latitude == null || longitude == null) return null;
    return _gps.distancia(posicao, latitude, longitude);
  }

  void _mostrarPerfil() {
    final usuario = widget.usuario;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meu perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FotoPerfil(avatar: usuario.avatar, tamanho: 72),
            const SizedBox(height: 12),
            if (usuario.nome.isNotEmpty) Text(usuario.nome),
            Text(usuario.email),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sair() async {
    setState(() => _saindo = true);
    try {
      await widget.sair();
    } catch (_) {
      _avisar('Não foi possível sair. Tente novamente.');
    } finally {
      if (mounted) setState(() => _saindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia de Turismo - Carapicuíba'),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: widget.alterarTema,
            icon: const Icon(Icons.dark_mode),
          ),
          PopupMenuButton<String>(
            tooltip: 'Conta',
            enabled: !_saindo,
            onSelected: (acao) {
              if (acao == 'perfil') {
                _mostrarPerfil();
              } else {
                _sair();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'perfil', child: Text('Meu perfil')),
              PopupMenuItem(value: 'sair', child: Text('Sair')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FotoPerfil(avatar: widget.usuario.avatar, tamanho: 28),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TextButton.icon(
            onPressed: _localizando ? null : _localizar,
            icon: const Icon(Icons.my_location),
            label: Text(
              _localizando ? 'Buscando localização…' : 'Usar minha localização',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _lugares.length + 1,
              itemBuilder: (context, indice) {
                if (indice == _lugares.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          if (_erro != null) Text(_erro!),
                          if (_carregando)
                            const CircularProgressIndicator()
                          else if (_temMais)
                            TextButton(
                              onPressed: _carregar,
                              child: Text(
                                _erro == null
                                    ? 'Carregar mais'
                                    : 'Tentar novamente',
                              ),
                            )
                          else if (_lugares.isEmpty)
                            const Text('Nenhum lugar encontrado.'),
                        ],
                      ),
                    ),
                  );
                }
                final lugar = _lugares[indice];
                final distancia = _distancia(lugar);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(lugar.nome),
                    subtitle: lugar.descricao.isEmpty
                        ? null
                        : Text(lugar.descricao),
                    trailing: distancia == null
                        ? null
                        : Text('${distancia.toStringAsFixed(1)} km'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
