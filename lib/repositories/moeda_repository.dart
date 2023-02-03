import 'package:crypo_app/models/moeda.dart';

class MoedaRepository {
  static List<Moeda> tabela = [
    Moeda(
      icone: 'assets/images/bitcoin.png',
      nome: 'BitCoin',
      sigla: 'BTC',
      preco: 118548.16,
    ),
    Moeda(
      icone: 'assets/images/ethereum.png',
      nome: 'Ethereum',
      sigla: 'ETH',
      preco: 8318.53,
    ),
    Moeda(
      icone: 'assets/images/xrp.png',
      nome: 'XRP',
      sigla: 'XRP',
      preco: 2.07,
    ),
    Moeda(
      icone: 'assets/images/cardano.png',
      nome: 'Cardano',
      sigla: 'CAR',
      preco: 2.01,
    ),
    Moeda(
      icone: 'assets/images/usdcoin.png',
      nome: 'USD Coin',
      sigla: 'USDT',
      preco: 5.05,
    ),
    Moeda(
      icone: 'assets/images/litecoin.png',
      nome: 'Litecoin',
      sigla: 'LIT',
      preco: 499.08,
    ),
  ];
}
