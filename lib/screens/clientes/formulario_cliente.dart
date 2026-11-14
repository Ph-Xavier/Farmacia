import 'package:flutter/material.dart';

// importa o componente Editor.
// ele padroniza os campos de texto usados no projeto.
import '../../components/editor.dart';

// importa o model Cliente.
import '../../models/cliente.dart';

// importa o repository.
// ele será responsável por decidir se o cliente será salvo
// no SQLite local ou na API remota.
import '../../repository/farmacia_repository.dart';

class FormularioCliente extends StatefulWidget {
  const FormularioCliente({super.key});

  @override
  State<FormularioCliente> createState() => _FormularioClienteState();
}

class _FormularioClienteState extends State<FormularioCliente> {
  // controlador do campo de nome.
  final TextEditingController _controladorNome = TextEditingController();

  // controlador do campo de código do cliente.
  final TextEditingController _controladorCodigo = TextEditingController();

  // controla se o app está salvando o cliente.
  //
  // false → não está salvando.
  // true  → está salvando.
  bool _salvando = false;

  @override
  void dispose() {
    // libera os controladores da memória ao fechar a tela.
    _controladorNome.dispose();
    _controladorCodigo.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // barra superior da tela.
      appBar: AppBar(title: const Text('Novo Cliente')),

      // permite rolagem caso o conteúdo não caiba na tela.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // campo para digitar o nome do cliente.
            Editor(
              controlador: _controladorNome,
              rotulo: 'Nome',
              dica: 'Ex: Maria Oliveira',
              icone: Icons.person,
              tipoTeclado: TextInputType.text,
            ),

            // campo para digitar o código do cliente.
            Editor(
              controlador: _controladorCodigo,
              rotulo: 'Código do cliente',
              dica: '0000',
              icone: Icons.numbers,
              tipoTeclado: TextInputType.number,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),

              // botão responsável por salvar o cliente.
              child: ElevatedButton(
                // se estiver salvando, o botão fica desabilitado.
                onPressed: _salvando ? null : _salvarCliente,

                // se estiver salvando, mostra um indicador.
                // caso contrário, mostra o texto "Salvar".
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // função responsável por validar e salvar o cliente.
  Future<void> _salvarCliente() async {
    // recupera o nome digitado e remove espaços antes e depois.
    final String nome = _controladorNome.text.trim();

    // tenta converter o código do cliente para inteiro.
    final int? codigo = int.tryParse(_controladorCodigo.text);

    // valida se o nome foi preenchido.
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do cliente.')),
      );
      return;
    }

    // valida se o código é um número válido e maior que zero.
    if (codigo == null || codigo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código do cliente inválido.')),
      );
      return;
    }

    // cria o objeto Cliente com os dados informados.
    final clienteCriado = Cliente(nome: nome, codigo: codigo);

    try {
      // indica que o salvamento começou.
      setState(() {
        _salvando = true;
      });

      // salva o cliente usando o repository.
      // o repository decidirá se o cliente será salvo:
      // - no SQLite local;
      // - ou na API remota.
      await RepositorioFarmacia.instancia.salvarCliente(clienteCriado);

      // se a tela não estiver mais montada, interrompe a execução.
      if (!mounted) return;

      // mostra mensagem de sucesso.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente salvo com sucesso.')),
      );

      // fecha a tela e volta para a lista.
      Navigator.pop(context);
    } catch (erro) {
      // se ocorrer erro, verifica se a tela ainda está montada.
      if (!mounted) return;

      // mostra mensagem de erro.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar cliente: $erro')));
    } finally {
      // o finally executa dando certo ou dando erro.
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }
}
