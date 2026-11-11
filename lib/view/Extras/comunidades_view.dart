import 'package:flutter/material.dart';
import '../../models/comunidade.dart';

class ComunidadesView extends StatefulWidget {
  const ComunidadesView({super.key});

  @override
  State<ComunidadesView> createState() => _ComunidadesViewState();
}

class _ComunidadesViewState extends State<ComunidadesView> {
  final _buscaController = TextEditingController();
  String _busca = '';
  String _temaSelecionado = 'Todas';
  final List<String> _temas = const [
    'Todas',
    'Literatura',
    'Poesia',
    'Pesquisa',
    'Clubes de leitura',
  ];

  final List<Comunidade> _comunidades = [
    Comunidade(
      nome: 'Clube dos Clássicos',
      descricao: 'Leituras compartilhadas de obras que atravessam gerações.',
      tema: 'Literatura',
      membros: 128,
    ),
    Comunidade(
      nome: 'Poesia em voz alta',
      descricao: 'Um espaço para versos, interpretações e novos poetas.',
      tema: 'Poesia',
      membros: 76,
    ),
    Comunidade(
      nome: 'Pesquisa sem fronteiras',
      descricao: 'Artigos, métodos e conversas para quem está pesquisando.',
      tema: 'Pesquisa',
      membros: 54,
    ),
    Comunidade(
      nome: 'Leitura de domingo',
      descricao: 'Escolhemos um livro e conversamos sobre ele durante o mês.',
      tema: 'Clubes de leitura',
      membros: 91,
    ),
  ];

  List<Comunidade> get _filtradas => _comunidades.where((comunidade) {
        final busca = _busca.trim().toLowerCase();
        final textoCombina = busca.isEmpty ||
            comunidade.nome.toLowerCase().contains(busca) ||
            comunidade.descricao.toLowerCase().contains(busca) ||
            comunidade.tema.toLowerCase().contains(busca);
        final temaCombina =
            _temaSelecionado == 'Todas' || comunidade.tema == _temaSelecionado;
        return textoCombina && temaCombina;
      }).toList();

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
    if (nova == null || !mounted) return;
    setState(() => _comunidades.insert(0, nova));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comunidade criada com sucesso.')),
    );
  }

  void _alternarParticipacao(Comunidade comunidade) {
    setState(() {
      comunidade.participando = !comunidade.participando;
      comunidade.membros += comunidade.participando ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comunidades = _filtradas;
    return Scaffold(
      appBar: AppBar(title: const Text('Comunidades')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarComunidade,
        icon: const Icon(Icons.add),
        label: const Text('Criar comunidade'),
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
            child: comunidades.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'Não encontramos comunidades com esses filtros.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                    itemCount: comunidades.length,
                    itemBuilder: (context, index) {
                      final comunidade = comunidades[index];
                      return _CartaoComunidade(
                        comunidade: comunidade,
                        aoAlternar: () => _alternarParticipacao(comunidade),
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
    required this.aoAlternar,
  });

  final Comunidade comunidade;
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
                Expanded(child: Text(comunidade.membros.toString() + ' membros')),
                comunidade.participando
                    ? OutlinedButton.icon(
                        onPressed: aoAlternar,
                        icon: const Icon(Icons.check),
                        label: const Text('Participando'),
                      )
                    : FilledButton.icon(
                        onPressed: aoAlternar,
                        icon: const Icon(Icons.group_add_outlined),
                        label: const Text('Participar'),
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
        membros: 1,
        participando: true,
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
