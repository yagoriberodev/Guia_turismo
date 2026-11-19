import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lugar.dart';
import '../models/usuario.dart';

class GuiaApi {
  static const endereco = 'https://guia.liliaborges.com.br';

  Future<Map<String, dynamic>> _ler(Future<http.Response> chamada) async {
    try {
      final resposta = await chamada.timeout(const Duration(seconds: 15));
      final texto = utf8.decode(resposta.bodyBytes);
      Map<String, dynamic>? json;
      try {
        final valor = jsonDecode(texto);
        if (valor is Map<String, dynamic>) json = valor;
      } on FormatException {
        // O servidor pode devolver uma página HTML quando está indisponível.
      }
      if (resposta.statusCode >= 200 &&
          resposta.statusCode < 300 &&
          json != null) {
        return json;
      }
      throw Exception(switch (resposta.statusCode) {
        401 => 'E-mail ou senha inválidos.',
        409 => 'Este e-mail já está cadastrado.',
        413 => 'A foto é grande demais para o servidor.',
        429 => 'Muitas tentativas. Aguarde um pouco.',
        >= 500 => 'O servidor está indisponível. Tente novamente.',
        _ =>
          json?['message'] is String
              ? json!['message'] as String
              : 'O servidor não concluiu a solicitação.',
      });
    } on TimeoutException {
      throw Exception('O servidor demorou a responder. Tente novamente.');
    } on http.ClientException {
      throw Exception('Não foi possível conectar à API. Confira a internet.');
    }
  }

  Future<Map<String, dynamic>> _post(
    String caminho,
    Map<String, String> dados,
  ) {
    return _ler(
      http.post(
        Uri.parse('$endereco$caminho'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      ),
    );
  }

  Future<void> cadastrar(
    String nome,
    String email,
    String senha,
    String avatar,
  ) async {
    await _post('/usuarios', {
      'nome': nome,
      'email': email,
      'senha': senha,
      'avatar': avatar,
    });
  }

  Future<Usuario> entrar(String email, String senha) async {
    final resposta = await _post('/login', {'email': email, 'senha': senha});
    final dados = resposta['data'];
    final token = resposta['token'] ?? (dados is Map ? dados['token'] : null);
    if (token is! String || token.isEmpty) {
      throw Exception('A API não enviou o token de acesso.');
    }
    final perfil = await _ler(
      http.get(
        Uri.parse('$endereco/usuarios/perfil'),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return Usuario.fromJson((perfil['data'] ?? perfil) as Map<String, dynamic>);
  }

  Future<List<Lugar>> listarLugares(int pagina) async {
    final resposta = await _ler(
      http.get(Uri.parse('$endereco/lugares?pagina=$pagina&limite=20')),
    );
    return (resposta['data'] as List)
        .map((item) => Lugar.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
