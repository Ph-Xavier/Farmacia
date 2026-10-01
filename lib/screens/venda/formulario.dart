import 'package:flutter/material.dart';
import '../../components/editor.dart';
import '../../models/venda_farmacia.dart';

class FormularioVenda extends StatefulWidget {
  const FormularioVenda({super.key});

  @override
  State<FormularioVenda> createState() => FormularioVendaState();
}

class FormularioVendaState extends State<FormularioVenda> {
  final TextEditingController _controladorCampoNumeroCupom =
      TextEditingController();
  final TextEditingController _controladorCampoValor = TextEditingController();

  static const _tituloAppBar = 'Registrando venda';
  static const _rotuloCampoValor = 'Valor';
  static const _dicaCampoValor = '0,00';

  static const _rotuloCampoNumeroCupom = 'Nº do cupom';
  static const _dicaCampoNumeroCupom = '0000';
  static const _textoBotaoConfirmar = 'Confirmar';

  @override
  void dispose() {
    _controladorCampoNumeroCupom.dispose();
    _controladorCampoValor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Editor(
              controlador: _controladorCampoNumeroCupom,
              rotulo: _rotuloCampoNumeroCupom,
              dica: _dicaCampoNumeroCupom,
            ),

            Editor(
              controlador: _controladorCampoValor,
              rotulo: _rotuloCampoValor,
              dica: _dicaCampoValor,
              icone: Icons.local_pharmacy,
            ),

            ElevatedButton(
              onPressed: () {
                _criaVenda(
                  context,
                  _controladorCampoNumeroCupom,
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

void _criaVenda(
  BuildContext context,
  TextEditingController controladorCampoNumeroCupom,
  TextEditingController controladorCampoValor,
) {
  final int? numeroCupom = int.tryParse(controladorCampoNumeroCupom.text);
  final double? valor = double.tryParse(controladorCampoValor.text);

  if (numeroCupom != null && valor != null) {
    final vendaCriada = VendaFarmacia(valor, numeroCupom);
    Navigator.pop(context, vendaCriada);
  }
}