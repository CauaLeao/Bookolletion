import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/comunidades_controller.dart';
import '../../models/comunidade.dart';

class ComunidadesView extends StatefulWidget {
  const ComunidadesView({super.key});

  @override
  State<ComunidadesView> createState() => _ComunidadesViewState();
}

class _ComunidadesViewState extends State<ComunidadesView> {
  final _buscaController = TextEditingController();
  final _controller = ComunidadesController();
  String _busca = '';
  String _temaSelecionado = 'Todas';
  late Stream<List<Comunidade>> _streamComunidades;
  bool _criando = false;
  final Set<String> _alterandoParticipacao = {};

  final List<String> _temas = const [
    'Todas',
    'Literatura',
    'Poesia',
    'Pesquisa',
    'Clubes de leitura',
  ];

  @override
  void initState() {
    super.initState();
    _streamComunidades = _controller.acompanharComunidades();
  }

  List<Comunidade> _filtrar(List<Comunidade> comunidades) =>
      comunidades.where((comunidade) {
        final busca = _busca.trim().toLowerCase();
        final textoCombina = busca.isEmpty ||
            comunidade.nome.toLowerCase().contains(busca) ||
            comunidade.descricao.toLowerCase().contains(busca) ||
            comunidade.tema.toLowerCase().contains(busca);
        final temaCombina =
            _temaSelecionado == 'Todas' || comunidade.tema == _temaSelecionado;
        return textoCombina && temaCombina;
      }).toList(growable: false);

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _criarComunidade() async {
    final nova = await showDialog<Comunidade>(
      context: context,
      builder: (_) => const _DialogCriarComunidade(),
    );
    if (nova == null || !mounted || _criando) return;
    setState(() => _criando = true);
    try {
      await _controller.criar(nova);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comunidade criada com sucesso.')),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível criar a comunidade: $erro')),
      );
    } finally {
      if (mounted) setState(() => _criando = false);
    }
  }

  Future<void> _alternarParticipacao(Comunidade comunidade) async {
    final id = comunidade.id;
    if (id == null || _alterandoParticipacao.contains(id)) return;
    setState(() => _alterandoParticipacao.add(id));
    try {
      await _controller.alternarParticipacao(comunidade);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível atualizar a participação: $erro')),
      );
    } finally {
      if (mounted) setState(() => _alterandoParticipacao.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comunidades')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criando ? null : _criarComunidade,
        icon: _criando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_criando ? 'Salvando...' : 'Criar comunidade'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text('Encontre seu espaço de leitura',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _buscaController,
              onChanged: (valor) => setState(() => _busca = valor),
              decoration: InputDecoration(
                hintText: 'Buscar comunidades',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busca.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: () {
                          _buscaController.clear();
                          setState(() => _busca = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: _temas.map((tema) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(tema),
                    selected: _temaSelecionado == tema,
                    onSelected: (_) => setState(() => _temaSelecionado = tema),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Comunidade>>(
              stream: _streamComunidades,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Não foi possível carregar as comunidades.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => setState(() {
                              _streamComunidades =
                                  _controller.acompanharComunidades();
                            }),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final comunidades = _filtrar(
                  snapshot.data ?? const <Comunidade>[],
                );
                if (comunidades.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'Não encontramos comunidades com esses filtros.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                  itemCount: comunidades.length,
                  itemBuilder: (context, index) {
                    final comunidade = comunidades[index];
                    return _CartaoComunidade(
                      comunidade: comunidade,
                      carregando: _alterandoParticipacao
                          .contains(comunidade.id),
                      aoAlternar: () => _alternarParticipacao(comunidade),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoComunidade extends StatelessWidget {
  const _CartaoComunidade({
    required this.comunidade,
    required this.carregando,
    required this.aoAlternar,
  });

  final Comunidade comunidade;
  final bool carregando;
  final VoidCallback aoAlternar;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cores.primaryContainer,
                  foregroundColor: cores.onPrimaryContainer,
                  child: const Icon(Icons.groups_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    comunidade.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(label: Text(comunidade.tema)),
              ],
            ),
            const SizedBox(height: 12),
            Text(comunidade.descricao),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 20),
                const SizedBox(width: 6),
                Expanded(child: Text('${comunidade.membros} membros')),
                comunidade.participando
                    ? OutlinedButton.icon(
                        onPressed: carregando ? null : aoAlternar,
                        icon: carregando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check),
                        label: Text(carregando ? 'Salvando...' : 'Participando'),
                      )
                    : FilledButton.icon(
                        onPressed: carregando ? null : aoAlternar,
                        icon: carregando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.group_add_outlined),
                        label: Text(carregando ? 'Salvando...' : 'Participar'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogCriarComunidade extends StatefulWidget {
  const _DialogCriarComunidade();

  @override
  State<_DialogCriarComunidade> createState() => _DialogCriarComunidadeState();
}

class _DialogCriarComunidadeState extends State<_DialogCriarComunidade> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  String _tema = 'Literatura';

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Comunidade(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tema: _tema,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const temas = ['Literatura', 'Poesia', 'Pesquisa', 'Clubes de leitura'];
    return AlertDialog(
      title: const Text('Criar comunidade'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (valor) =>
                    valor == null || valor.trim().length < 3
                        ? 'Informe um nome com pelo menos 3 caracteres'
                        : null,
              ),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                ),
                validator: (valor) =>
                    valor == null || valor.trim().isEmpty
                        ? 'Informe uma descrição'
                        : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tema,
                decoration: const InputDecoration(labelText: 'Tema'),
                items: temas
                    .map((tema) =>
                        DropdownMenuItem(value: tema, child: Text(tema)))
                    .toList(),
                onChanged: (valor) {
                  if (valor != null) setState(() => _tema = valor);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Criar')),
      ],
    );
  }
}
