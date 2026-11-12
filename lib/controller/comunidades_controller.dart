import 'dart:async';

import '../models/comunidade.dart';
import '../services/comunidade_service.dart';

class ComunidadesController {
  ComunidadesController({ComunidadeService? service})
      : _service = service ?? ComunidadeService();

  final ComunidadeService _service;

  Stream<List<Comunidade>> acompanharComunidades() =>
      _service.acompanharComunidades();

  Future<void> criar(Comunidade comunidade) => _service.criar(comunidade);

  Future<void> alternarParticipacao(Comunidade comunidade) =>
      _service.alternarParticipacao(comunidade);
}
