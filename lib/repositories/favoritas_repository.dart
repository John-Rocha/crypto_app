// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypo_app/database/db_firestore.dart';
import 'package:crypo_app/models/moeda.dart';
import 'package:crypo_app/repositories/moeda_repository.dart';
import 'package:crypo_app/services/auth_service.dart';
import 'package:flutter/cupertino.dart';

class FavoritasRepository extends ChangeNotifier {
  final List<Moeda> _lista = [];
  late FirebaseFirestore db;
  late AuthService auth;
  MoedaRepository moedas;

  FavoritasRepository({
    required this.auth,
    required this.moedas,
  }) {
    _startRepository();
  }

  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  void saveAll(List<Moeda> moedas) {
    moedas.forEach((Moeda moeda) async {
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        await db
            .collection('usuarios/${auth.usuario!.uid}/favoritas')
            .doc(moeda.sigla)
            .set({
          'user': auth.usuario!.email,
          'moeda': moeda.nome,
          'sigla': moeda.sigla,
          'preco': moeda.preco,
        });
      }
    });
    notifyListeners();
  }

  Future<void> remove(Moeda moeda) async {
    await db
        .collection('usuarios/${auth.usuario!.uid}/favoritas')
        .doc(moeda.sigla)
        .delete();
    _lista.remove(moeda);
    notifyListeners();
  }

  Future<void> _startRepository() async {
    await _startFirestore();
    await _readFavoritas();
  }

  Future<void> _readFavoritas() async {
    if (auth.usuario != null && _lista.isEmpty) {
      final snapshot =
          await db.collection('usuarios/${auth.usuario!.uid}/favoritas').get();

      snapshot.docs.forEach((doc) {
        Moeda moeda = moedas.tabela.firstWhere(
          (moeda) => moeda.sigla == doc.get('sigla'),
        );
        _lista.add(moeda);
        notifyListeners();
      });
    }
  }

  _startFirestore() {
    db = DbFirestore.get();
  }
}
