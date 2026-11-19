import 'dart:typed_data';

import 'package:flutter/material.dart';

class FotoPerfil extends StatelessWidget {
  final String? avatar;
  final double tamanho;

  const FotoPerfil({super.key, required this.avatar, required this.tamanho});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(avatar ?? '');
    final Widget? imagem;
    if (uri?.scheme == 'data' &&
        uri?.data?.mimeType.startsWith('image/') == true) {
      Uint8List? bytes;
      try {
        bytes = uri!.data!.contentAsBytes();
      } on FormatException {
        // Perfis antigos podem ter uma foto inválida.
      }
      imagem = bytes == null
          ? null
          : Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.person),
            );
    } else if (uri?.scheme == 'https') {
      imagem = Image.network(
        uri.toString(),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.person),
      );
    } else {
      imagem = null;
    }
    return CircleAvatar(
      radius: tamanho / 2,
      child: imagem == null
          ? Icon(Icons.person, size: tamanho * .55)
          : ClipOval(
              child: SizedBox.square(dimension: tamanho, child: imagem),
            ),
    );
  }
}
