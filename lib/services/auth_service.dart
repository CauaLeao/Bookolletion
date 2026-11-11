import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/usuario.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<Usuario> entrar({
    required String email,
    required String senha,
  }) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final usuarioFirebase = credencial.user;
    if (usuarioFirebase == null) {
      throw StateError('O Firebase não retornou o usuário autenticado.');
    }

    final documento = await _firestore
        .collection('usuarios')
        .doc(usuarioFirebase.uid)
        .get();
    final dados = documento.data();
    final dataNascimentoRaw = dados?['dataNascimento'];
    DateTime? dataNascimento;
    if (dataNascimentoRaw is Timestamp) {
      dataNascimento = dataNascimentoRaw.toDate();
    } else if (dataNascimentoRaw is String) {
      dataNascimento = DateTime.tryParse(dataNascimentoRaw);
    }

    return Usuario(
      nome: dados?['nome'] as String? ??
          usuarioFirebase.displayName ??
          usuarioFirebase.email?.split('@').first ??
          'Leitor',
      email: usuarioFirebase.email ?? email.trim(),
      telefone: dados?['telefone'] as String?,
      dataNascimento: dataNascimento,
    );
  }

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required DateTime dataNascimento,
    required String senha,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final usuarioFirebase = credencial.user;
    if (usuarioFirebase == null) {
      throw StateError('O Firebase não retornou o usuário criado.');
    }

    final usuario = Usuario(
      nome: nome.trim(),
      email: usuarioFirebase.email ?? email.trim(),
      telefone: telefone.trim(),
      dataNascimento: dataNascimento,
    );

    await _firestore.collection('usuarios').doc(usuarioFirebase.uid).set({
      'uid': usuarioFirebase.uid,
      'nome': usuario.nome,
      'email': usuario.email,
      'telefone': usuario.telefone,
      'dataNascimento': dataNascimento.toIso8601String(),
      'criadoEm': FieldValue.serverTimestamp(),
    });

    return usuario;
  }

  Future<void> enviarRedefinicaoSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (erro) {
      if (erro.code != 'user-not-found') rethrow;
    }
  }

  static String mensagemErro(Object erro) {
    if (erro is FirebaseAuthException) {
      return switch (erro.code) {
        'invalid-email' => 'O formato do e-mail é inválido.',
        'user-disabled' => 'Esta conta foi desativada.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'weak-password' => 'A senha é fraca. Use pelo menos 6 caracteres.',
        'operation-not-allowed' =>
          'O login por e-mail e senha não está habilitado no Firebase.',
        'too-many-requests' =>
          'Muitas tentativas. Aguarde um pouco e tente novamente.',
        'network-request-failed' =>
          'Sem conexão com a internet. Verifique sua rede.',
        _ => 'Erro no Firebase Auth (${erro.code}): ${erro.message ?? "sem detalhes"}.',
      };
    }

    if (erro is FirebaseException) {
      return switch (erro.code) {
        'permission-denied' =>
          'O Firebase negou o acesso. Confira as regras do Firestore.',
        'unavailable' =>
          'O Firebase está indisponível no momento. Tente novamente.',
        _ => 'Erro no Firestore (${erro.code}): ${erro.message ?? "sem detalhes"}.',
      };
    }

    return 'Erro inesperado (${erro.runtimeType}): $erro';
  }
}
