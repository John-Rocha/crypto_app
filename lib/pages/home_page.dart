import 'package:crypo_app/models/moeda.dart';
import 'package:crypo_app/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tabela = MoedaRepository.tabela;

  List<Moeda> selecionadas = [];

  NumberFormat real = NumberFormat.currency(
    locale: 'pt_BR',
    name: 'R\$',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: const Text('Cripto Moedas'),
        centerTitle: true,
      ),
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
            title: Text(
              moeda.nome,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              real.format(moeda.preco),
            ),
            selected: selecionadas.contains(moeda),
            selectedTileColor: Colors.indigo[50],
            onLongPress: () {
              setState(() {
                selecionadas.contains(moeda)
                    ? selecionadas.remove(moeda)
                    : selecionadas.add(moeda);
              });
            },
          );
        },
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: tabela.length,
      ),
    );
  }
}
