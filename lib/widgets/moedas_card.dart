import 'package:flutter/material.dart';

import 'package:crypo_app/models/moeda.dart';
import 'package:provider/provider.dart';

import '../pages/moeda_detalhes_page.dart';
import '../repositories/favoritas_repository.dart';
import '../utils/utils.dart';

class MoedasCard extends StatefulWidget {
  final Moeda moeda;

  const MoedasCard({
    super.key,
    required this.moeda,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MoedasCardState createState() => _MoedasCardState();
}

class _MoedasCardState extends State<MoedasCard> {
  static Map<String, Color> precoColor = <String, Color>{
    'up': Colors.teal,
    'down': Colors.indigo,
  };

  void showDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedaDetalhesPage(moeda: widget.moeda),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 22),
      elevation: 2,
      child: InkWell(
        onTap: () => showDetails(),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 20,
          ),
          child: Row(
            children: [
              Image.asset(
                widget.moeda.icone,
                height: 40,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.moeda.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.moeda.sigla,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: precoColor['down']!.withOpacity(0.05),
                  border: Border.all(
                    color: precoColor['down']!.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  Utils.real.format(widget.moeda.preco),
                  style: TextStyle(
                    fontSize: 16,
                    color: precoColor['down'],
                    letterSpacing: -1,
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text('Remover das Favoritas'),
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<FavoritasRepository>(
                          context,
                          listen: false,
                        ).remove(widget.moeda);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
