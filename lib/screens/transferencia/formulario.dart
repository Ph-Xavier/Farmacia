import 'package:flutter/material.dart';
import '../../components/editor.dart';
import '../../models/transferencia.dart';

class FormularioTransferencia extends StatefulWidget {
  const FormularioTransferencia({super.key});

  @override
  State<FormularioTransferencia> createState() =>
      FormularioTransferenciaState();
}

class FormularioTransferenciaState extends State<FormularioTransferencia> {
  final TextEditingController _controladorCampoNumeroConta =
      TextEditingController();
  final TextEditingController _controladorCampoValor = TextEditingController();

  static const _tituloAppBar = 'Criando transferência';
  static const _rotuloCampoValor = 'Valor';
  static const _dicaCampoValor = '0.00';

  static const _rotuloCampoNumeroConta = 'Número da conta';
  static const _dicaCampoNumeroConta = '0000';
  static const _textoBotaoConfirmar = 'Confirmar';

  @override
  void dispose() {
    _controladorCampoNumeroConta.dispose();
    _controladorCampoValor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
        // backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Editor(
              controlador: _controladorCampoNumeroConta,
              rotulo: _rotuloCampoNumeroConta,
              dica: _dicaCampoNumeroConta,
            ),

            Editor(
              controlador: _controladorCampoValor,
              rotulo: _rotuloCampoValor,
              dica: _dicaCampoValor,
              icone: Icons.monetization_on,
            ),

            ElevatedButton(
              onPressed: () {
                _criaTransferencia(
                  context,
                  _controladorCampoNumeroConta,
                  _controladorCampoValor,
                );
              },
              child: const Text(_textoBotaoConfirmar),
            ),
          ],
        ),
      ),
    );
  }
}

void _criaTransferencia(
  BuildContext context,
  TextEditingController controladorCampoNumeroConta,
  TextEditingController controladorCampoValor,
) {
  final int? numeroConta = int.tryParse(controladorCampoNumeroConta.text);
  final double? valor = double.tryParse(controladorCampoValor.text);

  if (numeroConta != null && valor != null) {
    final transferenciaCriada = Transferencia(valor, numeroConta);
    Navigator.pop(context, transferenciaCriada);
  }
}
