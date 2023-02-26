// ignore_for_file: prefer_final_fields

import 'package:crypo_app/database/db.dart';
import 'package:crypo_app/models/historico.dart';
import 'package:crypo_app/models/moeda.dart';
import 'package:crypo_app/repositories/moeda_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/posicao.dart';

class ContaRepository extends ChangeNotifier {
  late Database db;
  List<Posicao> _carteira = [];
  List<Historico> _historico = [];
  double _saldo = 0;
  MoedaRepository moedas;

  get saldo => _saldo;
  List<Posicao> get carteira => _carteira;
  List<Historico> get historico => _historico;

  ContaRepository({required this.moedas}) {
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _getSaldo();
    await _getCarteira();
    await _getHistorico();
  }

  _getSaldo() async {
    db = await Db.instance.database;
    List conta = await db.query('conta', limit: 1);
    _saldo = conta.first['saldo'];
    notifyListeners();
  }

  setSaldo(double valor) async {
    db = await Db.instance.database;
    db.update('conta', {
      'saldo': valor,
    });
    _saldo = valor;
    notifyListeners();
  }

  Future<void> comprar(Moeda moeda, double valor) async {
    db = await Db.instance.database;
    await db.transaction((txn) async {
      // Verificar se a moeda já foi comprada antes
      final posicaoMoeda = await txn.query(
        'carteira',
        where: 'sigla = ?',
        whereArgs: [moeda.sigla],
      );

      // Verifica se não tem a moeda em carteira
      if (posicaoMoeda.isEmpty) {
        await txn.insert(
          'carteira',
          {
            'sigla': moeda.sigla,
            'moeda': moeda.nome,
            'quantidade': (valor / moeda.preco).toString(),
          },
        );
      } else {
        final atual = double.parse(posicaoMoeda.first['quantidade'].toString());
        await txn.update(
          'carteira',
          {
            'quantidade': (atual + (valor / moeda.preco)).toString(),
          },
          where: 'sigla = ?',
          whereArgs: [moeda.sigla],
        );
      }

      // Inserir a compra no histórico
      await txn.insert('historico', {
        'sigla': moeda.sigla,
        'moeda': moeda.nome,
        'quantidade': (valor / moeda.preco).toString(),
        'valor': valor,
        'tipo_operacao': 'compra',
        'data_operacao': DateTime.now().millisecondsSinceEpoch,
      });

      // Atualizar o saldo
      await txn.update('conta', {'saldo': saldo - valor});
    });
    await _initRepository();
    notifyListeners();
  }

  Future<void> _getCarteira() async {
    _carteira = [];
    List posicoes = await db.query('carteira');
    for (var posicao in posicoes) {
      Moeda moeda = moedas.tabela.firstWhere(
        (moeda) => moeda.sigla == posicao['sigla'],
      );
      _carteira.add(Posicao(
        moeda: moeda,
        quantidade: double.parse(posicao['quantidade']),
      ));
    }
    notifyListeners();
  }

  _getHistorico() async {
    _historico = [];
    List operacoes = await db.query('historico');
    for (var operacao in operacoes) {
      Moeda moeda = moedas.tabela.firstWhere(
        (moeda) => moeda.sigla == operacao['sigla'],
      );
      _historico.add(
        Historico(
          dataOperacao: DateTime.fromMillisecondsSinceEpoch(
            operacao['data_operacao'],
          ),
          tipoOperacao: operacao['tipo_operacao'],
          moeda: moeda,
          valor: operacao['valor'],
          quantidade: double.parse(operacao['quantidade']),
        ),
      );
    }
    notifyListeners();
  }
}
