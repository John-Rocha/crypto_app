// ignore_for_file: library_private_types_in_public_api

import 'package:crypo_app/configs/app_settings.dart';
import 'package:crypo_app/repositories/conta_repository.dart';
import 'package:crypo_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({Key? key}) : super(key: key);

  @override
  _ConfiguracoesPageState createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool loading = false;
  _updateSaldo() async {
    final formKey = GlobalKey<FormState>();
    final valor = TextEditingController();
    final conta = context.read<ContaRepository>();

    valor.text = conta.saldo.toString();

    AlertDialog dialog = AlertDialog(
      title: const Text('Atualizar o Saldo'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: valor,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          validator: (value) {
            if (value!.isEmpty) return 'Informe o valor do saldo';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCELAR'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              conta.setSaldo(double.parse(valor.text));
              Navigator.of(context).pop();
            }
          },
          child: const Text('SALVAR'),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  Future<void> logout() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().logout();
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conta = context.watch<ContaRepository>();
    final loc = context.read<AppSettings>().locale;

    NumberFormat real = NumberFormat.currency(
      locale: loc['locale'],
      name: loc['name'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              title: const Text('Saldo'),
              subtitle: Text(
                real.format(conta.saldo),
                style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              trailing: IconButton(
                onPressed: _updateSaldo,
                icon: const Icon(Icons.edit),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: logout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: loading
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ]
                      : [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Sair do App',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          )
                        ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
