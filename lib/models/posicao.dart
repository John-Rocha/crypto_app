import 'package:crypo_app/models/moeda.dart';

class Posicao {
  final Moeda moeda;
  final double quantidade;

  Posicao({
    required this.moeda,
    required this.quantidade,
  });
}
