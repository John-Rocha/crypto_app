import 'dart:collection';

import 'package:crypo_app/models/moeda.dart';
import 'package:flutter/cupertino.dart';

class FavoritasRepository extends ChangeNotifier {
  List<Moeda> _lista = [];

  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  void saveAll(List<Moeda> moedas) {
    moedas.forEach((moeda) {
      if (!_lista.contains(moeda)) {
        _lista.add(moeda);
      }
    });
    notifyListeners();
  }

  void remove(Moeda moeda) {
    _lista.remove(moeda);
    notifyListeners();
  }
}
