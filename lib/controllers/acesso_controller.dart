import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../models/usuario.dart';
import '../services/google_auth.dart';
import '../services/guia_api.dart';

class AcessoController {
  final api = GuiaApi();
  final google = GoogleAuth();
  bool _sessaoGoogle = false;

  Future<Usuario> entrar(String email, String senha) {
    return api.entrar(email, senha);
  }

  Future<Usuario> entrarComGoogle() async {
    final usuario = await google.entrar();
    _sessaoGoogle = true;
    return usuario;
  }

  Future<void> sair() async {
    if (_sessaoGoogle) {
      await google.sair();
      _sessaoGoogle = false;
    }
  }

  Future<Uint8List?> escolherFoto(ImageSource origem) async {
    final foto = await ImagePicker().pickImage(
      source: origem,
      maxWidth: 240,
      maxHeight: 240,
      imageQuality: 65,
    );
    return foto?.readAsBytes();
  }

  Future<void> cadastrar(
    String nome,
    String email,
    String senha,
    Uint8List foto,
  ) {
    if (foto.length > 60 * 1024) {
      throw Exception('Escolha uma imagem menor para a foto do perfil.');
    }
    final String tipo;
    if (foto.length >= 3 &&
        foto[0] == 255 &&
        foto[1] == 216 &&
        foto[2] == 255) {
      tipo = 'jpeg';
    } else if (foto.length >= 4 &&
        foto[0] == 137 &&
        ascii.decode(foto.sublist(1, 4), allowInvalid: true) == 'PNG') {
      tipo = 'png';
    } else if (foto.length >= 12 &&
        ascii.decode(foto.sublist(8, 12), allowInvalid: true) == 'WEBP') {
      tipo = 'webp';
    } else {
      throw Exception('Escolha uma foto JPEG, PNG ou WebP.');
    }
    return api.cadastrar(
      nome,
      email,
      senha,
      'data:image/$tipo;base64,${base64Encode(foto)}',
    );
  }
}
