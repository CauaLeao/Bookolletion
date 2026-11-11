import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/publicacao.dart';

class PublicacaoService {
  PublicacaoService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> publicar(Publicacao publicacao) async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      throw StateError('É necessário entrar na conta para publicar.');
    }

    await _firestore.collection('publicacoes').add(
          publicacao.toMap(uid: usuario.uid),
        );
  }
}
