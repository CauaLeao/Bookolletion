import 'package:flutter/foundation.dart';

import '../models/publicacao.dart';
import '../services/publicacao_service.dart';

class PublicarController extends ChangeNotifier {
  PublicarController({PublicacaoService? service})
      : _service = service ?? PublicacaoService();

  final PublicacaoService _service;
  bool _carregando = false;

  bool get carregando => _carregando;

  Future<void> publicar(Publicacao publicacao) async {
    _carregando = true;
    notifyListeners();
    try {
      await _service.publicar(publicacao);
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }
}
