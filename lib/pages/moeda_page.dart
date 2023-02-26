import 'package:crypo_app/configs/app_settings.dart';
import 'package:crypo_app/models/moeda.dart';
import 'package:crypo_app/pages/moeda_detalhes_page.dart';
import 'package:crypo_app/repositories/favoritas_repository.dart';
import 'package:crypo_app/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoedaPage extends StatefulWidget {
  const MoedaPage({super.key});

  @override
  State<MoedaPage> createState() => _MoedaPageState();
}

class _MoedaPageState extends State<MoedaPage> with TickerProviderStateMixin {
  late List<Moeda> tabela;
  late NumberFormat real;
  late Map<String, String> loc;
  bool showFAB = true;
  List<Moeda> selecionadas = [];
  late FavoritasRepository favoritas;
  late MoedaRepository moedas;

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

  void readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(
      locale: loc['locale'],
      name: loc['name'],
    );
  }

  Widget changeLanguageButton() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['locale'] == 'pt_BR' ? '\$' : 'R\$';

    return PopupMenuButton(
      icon: const Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text('Usar $locale'),
            onTap: () {
              context.read<AppSettings>().setLocale(locale, name);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  StatefulWidget dynamicAppBar() {
    return selecionadas.isEmpty
        ? SliverAppBar(
            title: const Text('Cripto Moedas'),
            centerTitle: true,
            snap: true,
            floating: true,
            actions: [
              changeLanguageButton(),
            ],
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
    moedas = Provider.of<MoedaRepository>(context);
    tabela = moedas.tabela;
    readNumberFormat();

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, _) => [
          dynamicAppBar(),
        ],
        body: RefreshIndicator(
          onRefresh: () => moedas.checkPrecos(),
          child: ListView.separated(
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
                        child: Image.network(moeda.icone),
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
                    if (favoritas.lista.any((fav) => fav.sigla == moeda.sigla))
                      const Icon(
                        Icons.circle,
                        color: Colors.amber,
                        size: 8,
                      ),
                  ],
                ),
                trailing: Text(
                  real.format(moeda.preco),
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
