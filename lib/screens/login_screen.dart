import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/acesso_controller.dart';
import '../models/usuario.dart';

class LoginScreen extends StatefulWidget {
  final AcessoController acesso;
  final ValueChanged<Usuario> aoLogar;

  const LoginScreen({super.key, required this.acesso, required this.aoLogar});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formulario = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  Uint8List? _foto;
  bool _cadastro = false;
  bool _ocupado = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _executar(Future<void> Function() acao) async {
    setState(() => _ocupado = true);
    try {
      await acao();
    } catch (erro) {
      if (mounted) {
        final mensagem =
            erro is Exception && erro.toString().startsWith('Exception: ')
            ? erro.toString().substring(11)
            : 'Não foi possível concluir. Confira a conexão ou a configuração e tente novamente.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagem)));
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    final foto = _foto;
    if (_cadastro && foto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha uma foto de perfil.')),
      );
      return;
    }
    final email = _email.text.trim();
    final senha = _senha.text;
    await _executar(() async {
      if (_cadastro) {
        await widget.acesso.cadastrar(_nome.text.trim(), email, senha, foto!);
        if (!mounted) return;
        setState(() {
          _cadastro = false;
          _foto = null;
          _senha.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro concluído. Entre com seu e-mail e senha.'),
          ),
        );
      } else {
        final usuario = await widget.acesso.entrar(email, senha);
        if (mounted) widget.aoLogar(usuario);
      }
    });
  }

  Future<void> _escolherFoto() async {
    final temCamera =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (temCamera)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher imagem'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (!mounted || origem == null) return;
    await _executar(() async {
      final foto = await widget.acesso.escolherFoto(origem);
      if (mounted && foto != null) setState(() => _foto = foto);
    });
  }

  @override
  Widget build(BuildContext context) {
    final foto = _foto;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _cadastro
              ? 'Cadastro - Guia Carapicuíba'
              : 'Login - Guia Carapicuíba',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formulario,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_cadastro) ...[
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: foto == null ? null : MemoryImage(foto),
                      child: foto == null ? const Icon(Icons.person) : null,
                    ),
                    TextButton(
                      onPressed: _ocupado ? null : _escolherFoto,
                      child: Text(
                        foto == null ? 'Escolher foto' : 'Trocar foto',
                      ),
                    ),
                    TextFormField(
                      controller: _nome,
                      enabled: !_ocupado,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (valor) =>
                          valor!.trim().isEmpty ? 'Informe seu nome.' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _email,
                    enabled: !_ocupado,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (valor) =>
                        RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(valor!.trim())
                        ? null
                        : 'Informe um e-mail válido.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senha,
                    enabled: !_ocupado,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator: (valor) {
                      if (valor!.isEmpty) return 'Informe a senha.';
                      if (_cadastro && valor.length < 6) {
                        return 'Use pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _ocupado ? null : _enviar,
                    child: Text(_cadastro ? 'Cadastrar' : 'Entrar'),
                  ),
                  if (!_cadastro)
                    OutlinedButton(
                      onPressed: _ocupado
                          ? null
                          : () => _executar(() async {
                              final usuario = await widget.acesso
                                  .entrarComGoogle();
                              if (mounted) widget.aoLogar(usuario);
                            }),
                      child: const Text('Entrar com Google'),
                    ),
                  TextButton(
                    onPressed: _ocupado
                        ? null
                        : () => setState(() => _cadastro = !_cadastro),
                    child: Text(_cadastro ? 'Voltar ao login' : 'Criar conta'),
                  ),
                  if (_ocupado) const LinearProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
