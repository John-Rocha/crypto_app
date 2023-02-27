// ignore_for_file: library_private_types_in_public_api

import 'package:crypo_app/configs/app_settings.dart';
import 'package:crypo_app/repositories/moeda_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:crypo_app/models/moeda.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GraficoHistorico extends StatefulWidget {
  final Moeda moeda;

  const GraficoHistorico({
    super.key,
    required this.moeda,
  });

  @override
  _GraficoHistoricoState createState() => _GraficoHistoricoState();
}

enum Periodo { hora, dia, semana, mes, ano, total }

class _GraficoHistoricoState extends State<GraficoHistorico> {
  List<Color> cores = [
    const Color(0xFF3F51B5),
  ];

  Periodo periodo = Periodo.hora;
  List<Map<String, dynamic>> historico = [];
  List dadosCompletos = [];
  List<FlSpot> dadosGrafico = [];
  double maxX = 0;
  double maxY = 0;
  double minY = 0;

  ValueNotifier<bool> loaded = ValueNotifier(false);

  late MoedaRepository repository;
  late Map<String, dynamic> loc;
  late NumberFormat real;

  @override
  Widget build(BuildContext context) {
    repository = context.read<MoedaRepository>();
    loc = context.read<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);

    setDados();

    return AspectRatio(
      aspectRatio: 2,
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: loaded,
            builder: (context, isLoaded, _) {
              return (isLoaded)
                  ? LineChart(
                      getChartData(),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ),
        ],
      ),
    );
  }

  Future<void> setDados() async {
    loaded.value = false;
    dadosGrafico = [];

    if (historico.isEmpty) {
      historico = await repository.getHistoricoMoeda(widget.moeda);
    }

    dadosCompletos = historico[periodo.index]['prices'];
    dadosCompletos = dadosCompletos.reversed.map((item) {
      double preco = double.parse(item[0]);
      int time = int.parse('${item[1]}000');
      return [preco, DateTime.fromMillisecondsSinceEpoch(time)];
    }).toList();

    maxX = dadosCompletos.length.toDouble();
    maxY = 0;
    minY = double.infinity;

    for (var item in dadosCompletos) {
      maxY = item[0] > maxY ? item[0] : maxY;
      minY = item[0] < minY ? item[0] : minY;
    }

    for (var i = 0; i < dadosCompletos.length; i++) {
      dadosGrafico.add(FlSpot(
        i.toDouble(),
        dadosCompletos[i][0],
      ));
    }
    loaded.value = true;
  }

  LineChartData getChartData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      minY: minY,
      maxY: maxY,
    );
  }
}
