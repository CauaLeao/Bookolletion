import 'package:flutter/foundation.dart';

import '../models/livro.dart';

class EstanteProvider extends ChangeNotifier {
  final List<Livro> _livros = [
    Livro(
      titulo: 'Torto Arado',
      autor: 'Itamar Vieira Junior',
      sinopse: 'Uma história sobre memória, terra e identidade.',
      status: StatusLeitura.lendo,
    ),
    Livro(
      titulo: 'Quarto de Despejo',
      autor: 'Carolina Maria de Jesus',
      sinopse: 'O diário de uma mulher que narra a vida na favela.',
      status: StatusLeitura.lido,
    ),
    Livro(
      titulo: 'Dom Casmurro',
      autor: 'Machado de Assis',
      status: StatusLeitura.lido,
    ),
    Livro(
      titulo: 'A Hora da Estrela',
      autor: 'Clarice Lispector',
      status: StatusLeitura.queroLer,
    ),
  ];

  List<Livro> livrosPorStatus(StatusLeitura status) =>
      List.unmodifiable(_livros.where((livro) => livro.status == status));

  int quantidadePorStatus(StatusLeitura status) =>
      _livros.where((livro) => livro.status == status).length;

  bool contemLivro(Livro livro) => _livros.contains(livro);

  void adicionarLivro(Livro livro) {
    _livros.add(livro);
    notifyListeners();
  }

  void adicionarCitacao(Livro livro, String citacao) {
    if (!_livros.contains(livro)) return;
    _livros[_livros.indexOf(livro)].citacoes.add(citacao);
    notifyListeners();
  }

  void mudarStatus(Livro livro, StatusLeitura novoStatus) {
    final indice = _livros.indexOf(livro);
    if (indice == -1 || livro.status == novoStatus) return;

    _livros[indice].status = novoStatus;
    notifyListeners();
  }
}
