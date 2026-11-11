import 'package:flutter/material.dart';
import '../../models/publicacao.dart';
import 'package:google_fonts/google_fonts.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  TipoPublicacao? _filtro;


// lista publicação exemplos
  final List<Publicacao> _publicacoes = [
    Publicacao(
      tipo: TipoPublicacao.citacao,
      autor: 'Marina Costa',
      titulo: 'Uma frase que ficou comigo',
      conteudo: '“A leitura do mundo precede a leitura da palavra.”',
      detalhe: 'Paulo Freire • A importância do ato de ler',
      avaliacao: 0,
      curtidas: 18,
      comentarios: 4,
    ),
    Publicacao(
      tipo: TipoPublicacao.livro,
      autor: 'Rafael Lima',
      titulo: 'Recomendação de leitura',
      conteudo:
          'Uma leitura envolvente para quem gosta de refletir sobre escolhas, '
          'memória e as relações humanas.',
      detalhe: 'Torto Arado • Itamar Vieira Junior',
      avaliacao: 4.5,
      curtidas: 32,
      comentarios: 7,
    ),
    Publicacao(
      tipo: TipoPublicacao.artigo,
      autor: 'Ana Souza',
      titulo: 'Artigo para estudantes e pesquisadores',
      conteudo:
          'O texto discute como práticas de leitura podem contribuir para a '
          'formação crítica de estudantes.',
      detalhe: 'Educação • publicado em 2024',
      avaliacao: 4,
      curtidas: 11,
      comentarios: 2,
    ),
  ];

  List<Publicacao> get _publicacoesFiltradas {
    if (_filtro == null) return _publicacoes;
    return _publicacoes.where((item) => item.tipo == _filtro).toList();
  }

  String _nomeTipo(TipoPublicacao tipo) {
    switch (tipo) {
      case TipoPublicacao.citacao:
        return 'Citação';
      case TipoPublicacao.livro:
        return 'Livro';
      case TipoPublicacao.artigo:
        return 'Artigo';
    }
  }

// Ação comentar 
  Future<void> _comentar(Publicacao publicacao) async {
    final controller = TextEditingController();
    final enviouComentario = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Comentar publicação'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escreva seu comentário',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim().isNotEmpty,
            ),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (enviouComentario == true && mounted) {
      setState(() => publicacao.comentarios++);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentário adicionado.')),
      );
    }
  }


// Tela e botões
  @override
  Widget build(BuildContext context) {
    final publicacoes = _publicacoesFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Icon(
                Icons.auto_stories,
                size: 50,
                color: Color.fromARGB(255, 142, 96, 23),
              ),
        actions: [
          IconButton(
            tooltip: 'Comunidades',
            onPressed: () => Navigator.pushNamed(context, 'comunidades'),
            icon: const Icon(Icons.groups_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Afasta o ícone 16 pixels da borda direita
            child: IconButton(
              tooltip: 'Meu perfil',
            onPressed: () => Navigator.pushNamed(context, 'perfil'),
            icon: const Icon(Icons.account_circle_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Tela Inicial',
              style: GoogleFonts.alfaSlabOne(
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FiltroChip(
                  label: 'Tudo',
                  selecionado: _filtro == null,
                  onSelected: () => setState(() => _filtro = null),
                ),
                _FiltroChip(
                  label: 'Citações',
                  selecionado: _filtro == TipoPublicacao.citacao,
                  onSelected: () =>
                      setState(() => _filtro = TipoPublicacao.citacao),
                ),
                _FiltroChip(
                  label: 'Livros',
                  selecionado: _filtro == TipoPublicacao.livro,
                  onSelected: () =>
                      setState(() => _filtro = TipoPublicacao.livro),
                ),
                _FiltroChip(
                  label: 'Artigos',
                  selecionado: _filtro == TipoPublicacao.artigo,
                  onSelected: () =>
                      setState(() => _filtro = TipoPublicacao.artigo),
                ),
              ],
            ),
          ),
          Expanded(
            child: publicacoes.isEmpty
                ? const Center(child: Text('Nenhuma publicação neste filtro.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                    itemCount: publicacoes.length,
                    itemBuilder: (context, index) {
                      final publicacao = publicacoes[index];
                      return _CartaoPublicacao(
                        publicacao: publicacao,
                        nomeTipo: _nomeTipo(publicacao.tipo),
                        aoCurtir: () => setState(() {
                          publicacao.curtido = !publicacao.curtido;
                          publicacao.curtidas += publicacao.curtido ? 1 : -1;
                        }),
                        aoComentar: () => _comentar(publicacao),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'publicar');
        },
        child: const Icon(Icons.add), // Ícone interno do botão
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.label,
    required this.selecionado,
    required this.onSelected,
  });

  final String label;
  final bool selecionado;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selecionado,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _CartaoPublicacao extends StatelessWidget {
  const _CartaoPublicacao({
    required this.publicacao,
    required this.nomeTipo,
    required this.aoCurtir,
    required this.aoComentar,
  });

  final Publicacao publicacao;
  final String nomeTipo;
  final VoidCallback aoCurtir;
  final VoidCallback aoComentar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person_outline)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    publicacao.autor,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(label: Text(nomeTipo)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              publicacao.titulo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(publicacao.conteudo),
            const SizedBox(height: 10),
            Text(
              publicacao.detalhe,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (publicacao.avaliacao > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(publicacao.avaliacao.toString()),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: aoCurtir,
                  icon: Icon(
                    publicacao.curtido ? Icons.favorite : Icons.favorite_border,
                    color: publicacao.curtido ? Colors.red : null,
                  ),
                  label: Text('${publicacao.curtidas}'),
                ),
                TextButton.icon(
                  onPressed: aoComentar,
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text('${publicacao.comentarios}'),
                ),

              ],
            ),
          ],
        ),
      ),
    );
    
  }
}
