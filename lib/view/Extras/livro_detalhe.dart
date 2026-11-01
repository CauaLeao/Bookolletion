import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/livro.dart';
import '../../providers/estante_provider.dart';

class LivroDetalhe extends StatelessWidget {
  const LivroDetalhe({super.key, required this.livro});

  final Livro livro;

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

  @override
  Widget build(BuildContext context) {
    final estante = context.watch<EstanteProvider>();
    final estaNaEstante = estante.contemLivro(livro);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do livro')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8E17C), Color(0xFFE6BD52)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.auto_stories,
              size: 82,
              color: Color(0xFF8E6017),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            livro.titulo,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'por ${livro.autor}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ...List.generate(5, (indice) {
                final valorEstrela = indice + 1;
                final icone = livro.avaliacao >= valorEstrela
                    ? Icons.star
                    : livro.avaliacao >= valorEstrela - 0.5
                        ? Icons.star_half
                        : Icons.star_border;
                return Icon(icone, color: Colors.amber.shade700, size: 22);
              }),
              const SizedBox(width: 8),
              Text(
                livro.avaliacao > 0
                    ? livro.avaliacao.toStringAsFixed(1)
                    : 'Ainda sem avaliação',
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text('Sinopse', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            livro.sinopse.isEmpty
                ? 'Nenhuma sinopse foi adicionada para este livro.'
                : livro.sinopse,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 26),
          Text(
            'Citações compartilhadas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _adicionarCitacao(context, livro),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar citação deste livro'),
          ),
          const SizedBox(height: 8),
          if (livro.citacoes.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.format_quote),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ainda não há citações compartilhadas para este livro.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...livro.citacoes.map(
              (citacao) => Card(
                child: ListTile(
                  leading: const Icon(Icons.format_quote),
                  title: Text(citacao),
                  subtitle: const Text('Compartilhada pela comunidade'),
                ),
              ),
            ),
          const SizedBox(height: 26),
          Text(
            estaNaEstante ? 'Status na sua estante' : 'Adicionar à estante',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: StatusLeitura.values.map((status) {
              return ChoiceChip(
                label: Text(_nomeStatus(status)),
                selected: estaNaEstante && livro.status == status,
                onSelected: (_) {
                  if (estaNaEstante) {
                    estante.mudarStatus(livro, status);
                  } else {
                    livro.status = status;
                    estante.adicionarLivro(livro);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Livro marcado como ${_nomeStatus(status)}.'),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

Future<void> _adicionarCitacao(BuildContext context, Livro livro) async {
  final controller = TextEditingController();
  final citacao = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Adicionar citação'),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Digite a citação e confira a referência no livro.',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: const Text('Salvar citação'),
        ),
      ],
    ),
  );
  controller.dispose();

  if (citacao == null || citacao.isEmpty || !context.mounted) return;

  context.read<EstanteProvider>().adicionarCitacao(livro, citacao);
}
