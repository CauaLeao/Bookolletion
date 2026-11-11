import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/usuario.dart';
import '../../providers/usuario_provider.dart';
import '../../services/auth_service.dart';


class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});

  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _dataController = TextEditingController();
  bool _carregando = false;


  //Data nascimento       
  DateTime? _dataNascimento;

  
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _escolherData() async {
    final agora = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(agora.year - 18),
      firstDate: DateTime(1920),
      lastDate: agora,
    );
    if (escolhida != null) {
      setState(() {
        _dataNascimento = escolhida;
        _dataController.text = _formatarData(escolhida);
      });
    }
  }
  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate() || _carregando) return;
    setState(() => _carregando = true);

    try {
      final usuario = await AuthService().cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        dataNascimento: _dataNascimento!,
        senha: _senhaController.text,
      );
      if (!mounted) return;
      context.read<UsuarioProvider>().definirUsuario(usuario);
      Navigator.pushReplacementNamed(context, 'inicio');
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.mensagemErro(erro))),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }
  //Interface principal
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 246, 232),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 90,
                    color: Color.fromARGB(255, 142, 96, 23),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'BooKollection',
                      textAlign: TextAlign.center,
                    style: GoogleFonts.alfaSlabOne(
                      fontSize: 20,
                      color: const Color.fromARGB(255, 142, 96, 23),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo: ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().length < 3) {
                        return 'Informe um nome com pelo menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail: ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      final email = valor?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'Informe o e-mail';
                      }
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Informe um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone: ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe o telefone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    readOnly: true,
                    onTap: _escolherData,
                    controller: _dataController,
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento: ',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (_) {
                      if (_dataNascimento == null) {
                        return 'Informe a data de nascimento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha: ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe a senha';
                      }
                      if (valor.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmarSenhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar senha: ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Confirme a senha';
                      }
                      if (valor != _senhaController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),


                  const SizedBox(height: 30),
                  if (_carregando) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(250, 60),
                    ),
                    onPressed: _carregando ? null : _cadastrar,
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),


                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Já tem conta? Entrar'),
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

  