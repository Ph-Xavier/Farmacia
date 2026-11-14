import 'package:flutter/material.dart';

// importa o model de venda.
import '../../models/venda_farmacia.dart';

// importa o componente de campo de texto reutilizável.
import '../../components/editor.dart';

// importa o repository.
// ele decidirá se a venda será salva localmente ou remotamente.
import '../../repository/farmacia_repository.dart';

class FormularioVenda extends StatefulWidget {
  const FormularioVenda({super.key});

  @override
  State<FormularioVenda> createState() {
    return FormularioVendaState();
  }
}

class FormularioVendaState extends State<FormularioVenda> {
  // controlador do campo número do cupom.
  final TextEditingController _controladorCampoNumeroCupom =
      TextEditingController();

  // controlador do campo valor.
  final TextEditingController _controladorCampoValor = TextEditingController();

  static const _tituloAppBar = 'Registrando venda';
  static const _rotuloCampoValor = 'Valor';
  static const _dicaCampoValor = '0,00';
  static const _rotuloCampoNumeroCupom = 'Nº do cupom';
  static const _dicaCampoNumeroCupom = '0000';
  static const _textoBotaoConfirmar = 'Confirmar';

  // controla se o app está salvando a venda.
  //
  // false → não está salvando.
  // true  → está salvando.
  bool _salvando = false;

  @override
  void dispose() {
    // libera os controladores da memória quando a tela for fechada.
    _controladorCampoNumeroCupom.dispose();
    _controladorCampoValor.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // barra superior da tela.
      appBar: AppBar(title: const Text(_tituloAppBar)),

      // permite rolagem se o conteúdo não couber na tela.
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // campo para número do cupom.
            Editor(
              controlador: _controladorCampoNumeroCupom,
              rotulo: _rotuloCampoNumeroCupom,
              dica: _dicaCampoNumeroCupom,
              icone: Icons.receipt,
              tipoTeclado: TextInputType.number,
            ),

            // campo para valor da venda.
            Editor(
              controlador: _controladorCampoValor,
              rotulo: _rotuloCampoValor,
              dica: _dicaCampoValor,
              icone: Icons.local_pharmacy,
              tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),

              // botão responsável por confirmar a venda.
              child: ElevatedButton(
                // se estiver salvando, desabilita o botão.
                onPressed: _salvando ? null : _criaVenda,

                // se estiver salvando, exibe loading.
                // caso contrário, mostra o texto normal.
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(_textoBotaoConfirmar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // função responsável por validar e salvar a venda.
  Future<void> _criaVenda() async {
    // tenta converter o texto do campo número do cupom para int.
    final int? numeroCupom = int.tryParse(_controladorCampoNumeroCupom.text);

    // troca vírgula por ponto para aceitar entrada como 10,50.
    final textoValor = _controladorCampoValor.text.replaceAll(',', '.');

    // tenta converter o texto do campo valor para double.
    final double? valor = double.tryParse(textoValor);

    // valida número do cupom.
    if (numeroCupom == null || numeroCupom <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número do cupom inválido.')),
      );
      return;
    }

    // valida valor.
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor deve ser maior que 0.')),
      );
      return;
    }

    // cria o objeto venda.
    final vendaCriada = VendaFarmacia(valor, numeroCupom);

    try {
      // indica que o processo de salvamento começou.
      setState(() {
        _salvando = true;
      });

      // salva a venda usando o repository.
      //
      // o repository decide se salva no SQLite ou na API.
      await RepositorioFarmacia.instancia.salvarVenda(vendaCriada);

      // se a tela não estiver mais montada, interrompe.
      if (!mounted) return;

      // exibe mensagem de sucesso.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Venda salva com sucesso.')));

      // fecha a tela e retorna para a lista.
      Navigator.pop(context);
    } catch (erro) {
      // se a tela não estiver mais montada, interrompe.
      if (!mounted) return;

      // exibe mensagem de erro.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar venda: $erro')));
    } finally {
      // o finally executa dando certo ou dando erro.
      //
      // aqui encerramos o estado de salvamento.
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }
}
