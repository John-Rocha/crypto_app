// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:convert';

import 'package:crypo_app/models/moeda.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../database/db.dart';

class MoedaRepository extends ChangeNotifier {
  List<Moeda> _tabela = [];
  late Timer intervalo;

  List<Moeda> get tabela => _tabela;

  MoedaRepository() {
    _setupMoedaTable();
    _setupDadosTableMoeda();
    _readMoedasTable();
    _refreshPrecos();
  }

  Future<List<Map<String, dynamic>>> getHistoricoMoeda(Moeda moeda) async {
    List<Map<String, dynamic>> precos = [];
    final response = await http.get(
      Uri.parse(
        'https://api.coinbase.com/v2/assets/prices/${moeda.baseId}?base=BRL',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Map<String, dynamic> moedaPreco = json['data']['prices'];

      precos.add(moedaPreco['hour']);
      precos.add(moedaPreco['day']);
      precos.add(moedaPreco['week']);
      precos.add(moedaPreco['month']);
      precos.add(moedaPreco['year']);
      precos.add(moedaPreco['all']);
    }

    return precos;
  }

  Future<void> _setupMoedaTable() async {
    const String table = '''
      CREATE TABLE IF NOT EXISTS moedas (
        baseId TEXT PRIMARY KEY,
        sigla TEXT,
        nome TEXT,
        icone TEXT,
        preco TEXT,
        timestamp INTEGER,
        mudancaHora TEXT,
        mudancaDia TEXT,
        mudancaSemana TEXT,
        mudancaMes TEXT,
        mudancaAno TEXT,
        mudancaPeriodoTotal TEXT
      );
    ''';
    Database db = await Db.instance.database;
    await db.execute(table);
  }

  Future<void> _setupDadosTableMoeda() async {
    if (await _moedasTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> moedas = json['data'];
        Database db = await Db.instance.database;
        Batch batch = db.batch();

        for (var moeda in moedas) {
          final preco = moeda['latest_price'];
          final timestamp = DateTime.parse(preco['timestamp']);

          batch.insert('moedas', {
            'baseId': moeda['id'],
            'sigla': moeda['symbol'],
            'nome': moeda['name'],
            'icone': moeda['image_url'],
            'preco': moeda['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'mudancaHora': preco['percent_change']['hour'].toString(),
            'mudancaDia': preco['percent_change']['day'].toString(),
            'mudancaSemana': preco['percent_change']['week'].toString(),
            'mudancaMes': preco['percent_change']['month'].toString(),
            'mudancaAno': preco['percent_change']['year'].toString(),
            'mudancaPeriodoTotal': preco['percent_change']['all'].toString()
          });
        }
        await batch.commit(noResult: true);
      }
    }
  }

  Future<bool> _moedasTableIsEmpty() async {
    Database db = await Db.instance.database;
    List resultados = await db.query('moedas');
    return resultados.isEmpty;
  }

  Future<void> _readMoedasTable() async {
    Database db = await Db.instance.database;
    List resultados = await db.query('moedas');

    _tabela = resultados.map((row) {
      return Moeda(
        baseId: row['baseId'],
        icone: row['icone'],
        sigla: row['sigla'],
        nome: row['nome'],
        preco: double.parse(row['preco']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        mudancaHora: double.parse(row['mudancaHora']),
        mudancaDia: double.parse(row['mudancaDia']),
        mudancaSemana: double.parse(row['mudancaSemana']),
        mudancaMes: double.parse(row['mudancaMes']),
        mudancaAno: double.parse(row['mudancaAno']),
        mudancaPeriodoTotal: double.parse(row['mudancaPeriodoTotal']),
      );
    }).toList();
    notifyListeners();
  }

  Future<void> _refreshPrecos() async {
    intervalo = Timer.periodic(
      const Duration(minutes: 5),
      (_) => checkPrecos(),
    );
  }

  checkPrecos() async {
    String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> moedas = json['data'];
      Database db = await Db.instance.database;
      Batch batch = db.batch();

      for (var atual in _tabela) {
        for (var novo in moedas) {
          if (atual.baseId == novo['base_id']) {
            final moeda = novo['prices'];
            final preco = moeda['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);
            batch.update(
              'moedas',
              {
                'preco': moeda['latest'],
                'timestamp': timestamp.millisecondsSinceEpoch,
                'mudancaHora': preco['percent_change']['hour'].toString(),
                'mudancaDia': preco['percent_change']['day'].toString(),
                'mudancaSemana': preco['percent_change']['week'].toString(),
                'mudancaMes': preco['percent_change']['month'].toString(),
                'mudancaAno': preco['percent_change']['year'].toString(),
                'mudancaPeriodoTotal': preco['percent_change']['all'].toString()
              },
              where: 'baseId = ?',
              whereArgs: [atual.baseId],
            );
          }
        }
      }
      await batch.commit(noResult: true);
      await _readMoedasTable();
    }
  }
}
