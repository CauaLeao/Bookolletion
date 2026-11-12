import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comunidade.dart';

class ComunidadeService {
  ComunidadeService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<Comunidade>> acompanharComunidades() {
    final usuarioUid = _usuarioUid;
    return _firestore
        .collection('comunidades')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map(
          (resultado) => resultado.docs
              .map((documento) => Comunidade.fromFirestore(
                    documento,
                    usuarioUid: usuarioUid,
                  ))
              .toList(growable: false),
        );
  }

  Future<void> criar(Comunidade comunidade) async {
    await _firestore.collection('comunidades').add(
          comunidade.toMap(usuarioUid: _usuarioUid),
        );
  }

  Future<void> alternarParticipacao(Comunidade comunidade) async {
    final documentoId = comunidade.id;
    if (documentoId == null) {
      throw StateError('Não foi possível identificar esta comunidade.');
    }

    final participante = _usuarioUid;
    final campo = _firestore.collection('comunidades').doc(documentoId);
    await campo.update({
      'participantes': comunidade.participando
          ? FieldValue.arrayRemove([participante])
          : FieldValue.arrayUnion([participante]),
    });
  }

  String get _usuarioUid {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      throw StateError('Entre na sua conta para acessar as comunidades.');
    }
    return usuario.uid;
  }
}
