class Comunidade {
  Comunidade({
    required this.nome,
    required this.descricao,
    required this.tema,
    required this.membros,
    this.participando = false,
  });

  final String nome;
  final String descricao;
  final String tema;
  int membros;
  bool participando;
}
