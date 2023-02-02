import 'package:crypo_app/models/moeda.dart';

class MoedaRepository {
  static List<Moeda> tabela = [
    Moeda(
      icone: 'assets/images/bitcoin.png',
      nome: 'BitCoin',
      sigla: 'BTC',
      preco: 163521.00,
    ),
    Moeda(
      icone: 'assets/images/ethereum.png',
      nome: 'Ethereum',
      sigla: 'ETH',
      preco: 26541.00,
    ),
    Moeda(
      icone: 'assets/images/xrp.png',
      nome: 'XRP',
      sigla: 'XRP',
      preco: 155.20,
    ),
    Moeda(
      icone: 'assets/images/cardano.png',
      nome: 'Cardano',
      sigla: 'CAR',
      preco: 2654.00,
    ),
    Moeda(
      icone: 'assets/images/usdcoin.png',
      nome: 'USD Coin',
      sigla: 'USDT',
      preco: 5.20,
    ),
    Moeda(
      icone: 'assets/images/litecoin.png',
      nome: 'Litecoin',
      sigla: 'LIT',
      preco: 541.00,
    ),
  ];
}
