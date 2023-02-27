import 'package:crypo_app/models/moeda.dart';
import 'package:crypo_app/repositories/conta_repository.dart';
import 'package:crypo_app/utils/utils.dart';
import 'package:crypo_app/widgets/grafico_historico.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoedaDetalhesPage extends StatefulWidget {
  final Moeda moeda;

  const MoedaDetalhesPage({
    Key? key,
    required this.moeda,
  }) : super(key: key);

  @override
  State<MoedaDetalhesPage> createState() => _MoedaDetalhesPageState();
}

class _MoedaDetalhesPageState extends State<MoedaDetalhesPage> {
  final _formKey = GlobalKey<FormState>();
  final _valor = TextEditingController();

  double quantidade = 0;
  late ContaRepository conta;
  Widget grafico = const SizedBox();
  bool graficoLoaded = false;

  @override
  void dispose() {
    super.dispose();
    _valor.dispose();
  }

  Widget getGrafico() {
    if (!graficoLoaded) {
      grafico = GraficoHistorico(moeda: widget.moeda);
      graficoLoaded = true;
    }

    return grafico;
  }

  Future<void> comprar() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Salvar a compra
      await conta.comprar(widget.moeda, double.parse(_valor.text));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Compra realizada com sucesso!!'),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    conta = Provider.of<ContaRepository>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moeda.nome),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    widget.moeda.icone,
                    scale: 2.5,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Utils.real.format(widget.moeda.preco),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            (quantidade > 0)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.05),
                      ),
                      child: Text(
                        '$quantidade ${widget.moeda.sigla}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(bottom: 24),
                  ),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _valor,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  suffix: Text(
                    'reais',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Informe o valor da compra';
                  } else if (double.parse(value) < 50) {
                    return 'Compra mínima é de R\$ 50,00';
                  } else if (double.parse(value) > conta.saldo) {
                    return 'Você não tem saldo suficiente';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(
                    () {
                      quantidade = (value.isEmpty)
                          ? 0
                          : double.parse(value) / widget.moeda.preco;
                    },
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: comprar,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Comprar',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
