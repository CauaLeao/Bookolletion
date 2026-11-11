
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/publicar_controller.dart';
import '../../models/publicacao.dart';
import '../../providers/usuario_provider.dart';

class PublicarView extends StatelessWidget {
  const PublicarView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        
        appBar: AppBar(
          title: const Text('Criar publicação'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Citação', icon: Icon(Icons.format_quote)),
              Tab(text: 'Livro', icon: Icon(Icons.menu_book_outlined)),
              Tab(text: 'Artigo/Tese', icon: Icon(Icons.article_outlined)),
            ],
          ),


        ),
        body: TabBarView(
          children: [
            _FormularioPublicacao(
              tipo: TipoPublicacao.citacao,
              tituloDaTela: 'Compartilhe uma citação',
              rotuloTitulo: 'Título da publicação',
              rotuloConteudo: 'Citação ou frase',
              rotuloDetalhe: 'Livro e autor da obra (opcional)',
              dicaConteudo: 'Escreva a frase que marcou você',
            ),


            _FormularioPublicacao(
              tipo: TipoPublicacao.livro,
              tituloDaTela: 'Recomende um livro',
              rotuloTitulo: 'Título do livro',
              rotuloConteudo: 'Sua recomendação',
              rotuloDetalhe: 'Autor do livro',
              dicaConteudo: 'O que outras pessoas deveriam saber sobre ele?',
              mostrarAvaliacao: true,
            ),


            _FormularioPublicacao(
              tipo: TipoPublicacao.artigo,
              tituloDaTela: 'Compartilhe um artigo ou tese',
              rotuloTitulo: 'Título do artigo ou tese',
              rotuloConteudo: 'Resumo ou comentário',
              rotuloDetalhe: 'Autor(es) ou área de estudo',
              dicaConteudo: 'Apresente brevemente o conteúdo e sua opinião',
              mostrarAvaliacao: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormularioPublicacao extends StatefulWidget {
  const _FormularioPublicacao({
    required this.tipo,
    required this.tituloDaTela,
    required this.rotuloTitulo,
    required this.rotuloConteudo,
    required this.rotuloDetalhe,
    required this.dicaConteudo,
    this.mostrarAvaliacao = false,
  });

  final TipoPublicacao tipo;
  final String tituloDaTela;
  final String rotuloTitulo;
  final String rotuloConteudo;
  final String rotuloDetalhe;
  final String dicaConteudo;
  final bool mostrarAvaliacao;

  @override
  State<_FormularioPublicacao> createState() => _FormularioPublicacaoState();
}

class _FormularioPublicacaoState extends State<_FormularioPublicacao> {
  final _formKey = GlobalKey<FormState>();
  final _notaKey = GlobalKey<FormFieldState<double>>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  final _detalheController = TextEditingController();
  final _publicarController = PublicarController();

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    _detalheController.dispose();
    _publicarController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = context.read<UsuarioProvider>().usuario;
    final publicacao = Publicacao(
      tipo: widget.tipo,
      autor: usuario?.nome ?? 'Leitor',
      titulo: _tituloController.text.trim(),
      conteudo: _conteudoController.text.trim(),
      detalhe: _detalheController.text.trim().isEmpty
          ? 'Citação sem referência informada'
          : _detalheController.text.trim(),
      avaliacao: widget.mostrarAvaliacao ? _notaKey.currentState!.value! : 0,
      curtidas: 0,
      comentarios: 0,
    );

    try {
      await _publicarController.publicar(publicacao);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicação salva no Firestore!')),
      );
      Navigator.pop(context);
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível publicar: $erro')),
      );
    }
  }

  String? _validarObrigatorio(String? valor, String nomeCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Preencha $nomeCampo';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.tituloDaTela,
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),
          const Text('Compartilhe algo útil para quem também está lendo.'),
          const SizedBox(height: 24),
          TextFormField(
            controller: _tituloController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: widget.rotuloTitulo,
              border: const OutlineInputBorder(),
            ),
            validator: (valor) => _validarObrigatorio(valor, 'o título'),
          ),

          const SizedBox(height: 16),
          
          TextFormField(
            controller: _conteudoController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 4,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: widget.rotuloConteudo,
              hintText: widget.dicaConteudo,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
            validator: (valor) => _validarObrigatorio(valor, 'o conteúdo'),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _detalheController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: widget.rotuloDetalhe,
              border: const OutlineInputBorder(),
            ),
            validator: widget.tipo == TipoPublicacao.citacao
                ? null
                : (valor) => _validarObrigatorio(valor, 'este campo'),
          ),

          if (widget.mostrarAvaliacao) ...[
            
            const SizedBox(height: 20),

            FormField<double>(
              key: _notaKey,
              initialValue: 0,
              validator: (nota) =>
                  nota == null || nota == 0 ? 'Escolha uma nota' : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sua avaliação'),
                  Row(
                    children: List.generate(5, (indice) {
                      final estrela = indice + 1;
                      return IconButton(
                        tooltip: '$estrela estrelas',
                        onPressed: () => field.didChange(estrela.toDouble()),
                        icon: Icon(
                          estrela <= (field.value ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber.shade700,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  if (field.errorText != null)

                    Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          
          ListenableBuilder(
            listenable: _publicarController,
            builder: (context, _) => FilledButton.icon(
              onPressed: _publicarController.carregando ? null : _enviar,
              icon: _publicarController.carregando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(_publicarController.carregando
                  ? 'Salvando...'
                  : 'Publicar no feed'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          SizedBox(height: 30,),

          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, 'inicio'), 
            child:
            Text(
                'Voltar', 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
          )
        ],
      ),
    );
  }
}
