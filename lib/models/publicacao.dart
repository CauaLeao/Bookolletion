import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoPublicacao { citacao, livro, artigo }

class Publicacao {
  Publicacao({
    required this.tipo,
    required this.autor,
    required this.titulo,
    required this.conteudo,
    required this.detalhe,
    required this.avaliacao,
    required this.curtidas,
    required this.comentarios,
    this.id,
    this.uid,
  });

  final String? id;
  final String? uid;
  final TipoPublicacao tipo;
  final String autor;
  final String titulo;
  final String conteudo;
  final String detalhe;
  final double avaliacao;
  int curtidas;
  int comentarios;
  bool curtido = false;

  Map<String, dynamic> toMap({required String uid}) => {
        'uid': uid,
        'tipo': tipo.name,
        'autor': autor,
        'titulo': titulo,
        'conteudo': conteudo,
        'detalhe': detalhe,
        'avaliacao': avaliacao,
        'curtidas': curtidas,
        'comentarios': comentarios,
        'criadoEm': FieldValue.serverTimestamp(),
      };

  factory Publicacao.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data()!;
    return Publicacao(
      id: documento.id,
      uid: dados['uid'] as String?,
      tipo: TipoPublicacao.values.firstWhere(
        (tipo) => tipo.name == dados['tipo'],
        orElse: () => TipoPublicacao.citacao,
      ),
      autor: dados['autor'] as String? ?? 'Leitor',
      titulo: dados['titulo'] as String? ?? '',
      conteudo: dados['conteudo'] as String? ?? '',
      detalhe: dados['detalhe'] as String? ?? '',
      avaliacao: (dados['avaliacao'] as num?)?.toDouble() ?? 0,
      curtidas: dados['curtidas'] as int? ?? 0,
      comentarios: dados['comentarios'] as int? ?? 0,
    );
  }
}
