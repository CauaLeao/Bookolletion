enum StatusLeitura { lendo, lido, queroLer }

class Livro {
  Livro({
    required this.titulo,
    required this.autor,
    required this.status,
    this.sinopse = '',
    this.avaliacao = 0,
    List<String>? citacoes,
  }) : citacoes = citacoes ?? [];

  final String titulo;
  final String autor;
  final String sinopse;
  final double avaliacao;
  final List<String> citacoes;
  StatusLeitura status;
}
