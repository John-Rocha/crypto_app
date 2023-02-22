import 'package:crypo_app/models/moeda.dart';

class Historico {
  final DateTime dataOperacao;
  final String tipoOperacao;
  final Moeda moeda;
  final double valor;
  final double quantidade;

  Historico({
    required this.dataOperacao,
    required this.tipoOperacao,
    required this.moeda,
    required this.valor,
    required this.quantidade,
  });
}
