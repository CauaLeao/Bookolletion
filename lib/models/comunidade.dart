import 'package:cloud_firestore/cloud_firestore.dart';

class Comunidade {
  Comunidade({
    required this.nome,
    required this.descricao,
    required this.tema,
    this.id,
    this.criadorUid,
    this.participantes = const [],
    this.participando = false,
  });

  final String? id;
  final String? criadorUid;
  final String nome;
  final String descricao;
  final String tema;
  final List<String> participantes;
  final bool participando;

  int get membros => participantes.length;

  Map<String, dynamic> toMap({required String usuarioUid}) => {
        'criadorUid': usuarioUid,
        'nome': nome,
        'descricao': descricao,
        'tema': tema,
        'participantes': [usuarioUid],
        'criadoEm': FieldValue.serverTimestamp(),
      };

  factory Comunidade.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> documento, {
    required String usuarioUid,
  }) {
    final dados = documento.data();
    final participantesRaw = dados['participantes'];
    final participantes = participantesRaw is List
        ? participantesRaw.whereType<String>().toList(growable: false)
        : <String>[];

    return Comunidade(
      id: documento.id,
      criadorUid: dados['criadorUid'] as String?,
      nome: dados['nome'] as String? ?? 'Comunidade',
      descricao: dados['descricao'] as String? ?? '',
      tema: dados['tema'] as String? ?? 'Literatura',
      participantes: participantes,
      participando: participantes.contains(usuarioUid),
    );
  }
}
