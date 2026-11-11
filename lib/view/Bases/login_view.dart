import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/usuario_provider.dart';
import '../../services/auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;
  bool _mostrarSenha = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate() || _carregando) return;
    setState(() => _carregando = true);

    try {
      final usuario = await _authService.entrar(
        email: _emailController.text,
        senha: _senhaController.text,
      );
      if (!mounted) return;
      context.read<UsuarioProvider>().definirUsuario(usuario);
      Navigator.pushReplacementNamed(context, 'inicio');
    } catch (erro) {
      if (mounted) _mostrarErro(AuthService.mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 246, 232),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 82,
                    color: Color.fromARGB(255, 142, 96, 23),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'BooKollection',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alfaSlabOne(
                      fontSize: 25,
                      color: const Color.fromARGB(255, 142, 96, 23),
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      final email = valor?.trim() ?? '';
                      if (email.isEmpty) return 'Informe seu e-mail';
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(email)) {
                        return 'Informe um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: !_mostrarSenha,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _entrar(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
                        onPressed: () =>
                            setState(() => _mostrarSenha = !_mostrarSenha),
                        icon: Icon(
                          _mostrarSenha
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (valor) => valor == null || valor.isEmpty
                        ? 'Informe sua senha'
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, 'recuperar_senha'),
                      child: const Text('Esqueceu a senha?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _entrar,
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, 'cadastro_usuario'),
                    child: const Text('Ainda não tem conta? Cadastre-se'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, 'sobre'),
                    child: const Text('Sobre o BooKollection'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
