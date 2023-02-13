// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:collection';

import 'package:crypo_app/models/moeda.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';

import '../adapters/moeda_hive_adapter.dart';

class FavoritasRepository extends ChangeNotifier {
  final List<Moeda> _lista = [];
  late LazyBox box;

  FavoritasRepository() {
    _startRepository();
  }

  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  void saveAll(List<Moeda> moedas) {
    for (var moeda in moedas) {
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        box.put(moeda.sigla, moeda);
      }
    }
    notifyListeners();
  }

  void remove(Moeda moeda) {
    _lista.remove(moeda);
    box.delete(moeda.sigla);
    notifyListeners();
  }

  Future<void> _startRepository() async {
    await _openBox();
    await _readFavoritas();
  }

  Future<void> _openBox() async {
    Hive.registerAdapter(MoedaHiveAdapter());
    box = await Hive.openLazyBox('moedas_favoritas');
  }

  Future<void> _readFavoritas() async {
    box.keys.forEach((moeda) async {
      Moeda m = await box.get(moeda);
      _lista.add(m);
      notifyListeners();
    });
  }
}
