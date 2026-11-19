import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/usuario.dart';

class GoogleAuth {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const _webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  bool _googleInicializado = false;

  Future<Usuario> entrar() async {
    final android = defaultTargetPlatform == TargetPlatform.android;
    if (!kIsWeb && !android) {
      throw Exception('Use o Android ou o navegador para entrar com Google.');
    }
    if ([_apiKey, _appId, _projectId, _senderId].contains('') ||
        (!kIsWeb && _webClientId.isEmpty)) {
      throw Exception('Configure o projeto Firebase conforme o README.');
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: _apiKey,
          appId: _appId,
          projectId: _projectId,
          messagingSenderId: _senderId,
          authDomain: '$_projectId.firebaseapp.com',
        ),
      );
    }

    final auth = FirebaseAuth.instance;
    final UserCredential credencial;
    if (kIsWeb) {
      credencial = await auth.signInWithPopup(
        GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'}),
      );
    } else {
      final google = GoogleSignIn.instance;
      if (!_googleInicializado) {
        await google.initialize(serverClientId: _webClientId);
        _googleInicializado = true;
      }
      final conta = await google.authenticate();
      final token = conta.authentication.idToken;
      if (token == null) {
        throw Exception('O Google não enviou o token de acesso.');
      }
      credencial = await auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: token),
      );
    }
    final usuario = credencial.user;
    if (usuario == null) throw Exception('Não foi possível entrar com Google.');
    return Usuario(
      usuario.displayName ?? '',
      usuario.email ?? '',
      usuario.photoURL,
    );
  }

  Future<void> sair() async {
    await FirebaseAuth.instance.signOut();
    if (_googleInicializado) await GoogleSignIn.instance.signOut();
  }
}
