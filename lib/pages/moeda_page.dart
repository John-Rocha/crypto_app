import 'package:crypo_app/models/moeda.dart';
import 'package:crypo_app/pages/moeda_detalhes_page.dart';
import 'package:crypo_app/repositories/favoritas_repository.dart';
import 'package:crypo_app/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';

class MoedaPage extends StatefulWidget {
  const MoedaPage({super.key});

  @override
  State<MoedaPage> createState() => _MoedaPageState();
}

class _MoedaPageState extends State<MoedaPage> with TickerProviderStateMixin {
  final tabela = MoedaRepository.tabela;
  bool showFAB = true;
  List<Moeda> selecionadas = [];
  late FavoritasRepository favoritas;

  late AnimationController _controller;

  late CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 400),
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _animation.dispose();
  }

  StatefulWidget dynamicAppBar() {
    return selecionadas.isEmpty
        ? const SliverAppBar(
            title: Text('Cripto Moedas'),
            centerTitle: true,
            snap: true,
            floating: true,
          )
        : SliverAppBar(
            snap: true,
            floating: true,
            leading: IconButton(
              onPressed: () {
                setState(() {
                  selecionadas.clear();
                });
              },
              icon: const Icon(Icons.close),
            ),
            title: Text(
              '${selecionadas.length} selecionadas',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueGrey[50],
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.black87),
          );
  }

  void showDetails(Moeda moeda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedaDetalhesPage(moeda: moeda),
      ),
    );
  }

  void limparSelecionadas() {
    selecionadas.clear();
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<FavoritasRepository>(context);

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, _) => [
          dynamicAppBar(),
        ],
        body: ListView.separated(
          itemBuilder: (context, index) {
            final moeda = tabela[index];
            return ListTile(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              leading: !selecionadas.contains(moeda)
                  ? SizedBox(
                      width: 40,
                      child: Image.asset(moeda.icone),
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.check),
                    ),
              title: Row(
                children: [
                  Text(
                    moeda.nome,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (favoritas.lista.contains(moeda))
                    const Icon(
                      Icons.circle,
                      color: Colors.amber,
                      size: 8,
                    ),
                ],
              ),
              trailing: Text(
                Utils.real.format(moeda.preco),
              ),
              selected: selecionadas.contains(moeda),
              selectedTileColor: Colors.indigo[50],
              onLongPress: () {
                setState(
                  () {
                    selecionadas.contains(moeda)
                        ? selecionadas.remove(moeda)
                        : selecionadas.add(moeda);
                  },
                );
              },
              onTap: () => showDetails(moeda),
            );
          },
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: tabela.length,
        ),
      ),
      floatingActionButton: selecionadas.isNotEmpty
          ? ScaleTransition(
              scale: _animation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  favoritas.saveAll(selecionadas);
                  limparSelecionadas();
                },
                icon: const Icon(Icons.star),
                label: const Text(
                  'FAVORITAR',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
