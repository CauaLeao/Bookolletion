import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/livro.dart';
import '../../providers/estante_provider.dart';
import 'livro_detalhe.dart';

class EstanteView extends StatelessWidget {
  const EstanteView({super.key});

  @override
  Widget build(BuildContext context) {
    final estante = context.watch<EstanteProvider>();
    final lendo = estante.quantidadePorStatus(StatusLeitura.lendo);
    final lidos = estante.quantidadePorStatus(StatusLeitura.lido);
    final queroLer = estante.quantidadePorStatus(StatusLeitura.queroLer);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minha estante'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Lendo ($lendo)'),
              Tab(text: 'Lidos ($lidos)'),
              Tab(text: 'Quero ler ($queroLer)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListaLivros(status: StatusLeitura.lendo),
            _ListaLivros(status: StatusLeitura.lido),
            _ListaLivros(status: StatusLeitura.queroLer),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _abrirFormulario(context),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar livro'),
        ),
      ),
    );
  }

  Future<void> _abrirFormulario(BuildContext context) async {
    final livro = await showDialog<Livro>(
      context: context,
      builder: (_) => const _DialogAdicionarLivro(),
    );

    if (livro == null || !context.mounted) return;

    context.read<EstanteProvider>().adicionarLivro(livro);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro adicionado à estante.')),
    );
  }
}

class _ListaLivros extends StatelessWidget {
  const _ListaLivros({required this.status});

  final StatusLeitura status;

  void _abrirDetalhes(BuildContext context, Livro livro) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LivroDetalhe(livro: livro),
      ),
    );
  }

  String get _mensagemVazia {
    switch (status) {
      case StatusLeitura.lendo:
        return 'Você ainda não está lendo nenhum livro.';
      case StatusLeitura.lido:
        return 'Os livros que terminar aparecerão aqui.';
      case StatusLeitura.queroLer:
        return 'Adicione livros que deseja ler depois.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final livros = context.watch<EstanteProvider>().livrosPorStatus(status);

    if (livros.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(_mensagemVazia, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: livros.length,
      itemBuilder: (context, index) {
        final livro = livros[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () => _abrirDetalhes(context, livro),
            leading: Container(
              width: 48,
              height: 58,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_stories,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              livro.titulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              livro.sinopse.isEmpty
                  ? livro.autor
                  : '${livro.autor}\n${livro.sinopse}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: livro.sinopse.isNotEmpty,
            trailing: IconButton(
              tooltip: 'Ver detalhes do livro',
              onPressed: () => _abrirDetalhes(context, livro),
              icon: const Icon(Icons.chevron_right),
            ),
          ),
        );
      },
    );
  }
}

class _DialogAdicionarLivro extends StatefulWidget {
  const _DialogAdicionarLivro();

  @override
  State<_DialogAdicionarLivro> createState() => _DialogAdicionarLivroState();
}

class _DialogAdicionarLivroState extends State<_DialogAdicionarLivro> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _sinopseController = TextEditingController();
  StatusLeitura _status = StatusLeitura.queroLer;

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _sinopseController.dispose();
    super.dispose();
  }

  String _nomeStatus(StatusLeitura status) {
    switch (status) {
      case StatusLeitura.lendo:
        return 'Lendo';
      case StatusLeitura.lido:
        return 'Lidos';
      case StatusLeitura.queroLer:
        return 'Quero ler';
    }
  }

  void _adicionar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Livro(
        titulo: _tituloController.text.trim(),
        autor: _autorController.text.trim(),
        sinopse: _sinopseController.text.trim(),
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar livro'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Informe o título do livro'
                    : null,
              ),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Informe o autor'
                    : null,
              ),
              TextFormField(
                controller: _sinopseController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Sinopse (opcional)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<StatusLeitura>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: StatusLeitura.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_nomeStatus(status)),
                      ),
                    )
                    .toList(),
                onChanged: (status) {
                  if (status != null) setState(() => _status = status);
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
        FilledButton(
          onPressed: _adicionar,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
