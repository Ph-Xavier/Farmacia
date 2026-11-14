import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// importa o model de venda.
import '../../models/venda_farmacia.dart';

// importa o formulário de nova venda.
import 'formulario.dart';

// importa o repository.
// a tela não precisa saber se os dados vêm do SQLite ou da API.
import '../../repository/farmacia_repository.dart';

class ListaVendas extends StatefulWidget {
  const ListaVendas({super.key});

  @override
  State<ListaVendas> createState() {
    return ListaVendasState();
  }
}

class ListaVendasState extends State<ListaVendas> {
  static const _tituloAppBar = 'Vendas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // barra superior da tela.
      appBar: AppBar(title: const Text(_tituloAppBar)),

      // o FutureBuilder é usado porque tanto SQLite quanto API
      // trabalham com operações assíncronas.
      body: FutureBuilder<List<VendaFarmacia>>(
        // a tela chama o repository.
        // o repository decide se busca no SQLite ou na API.
        future: RepositorioFarmacia.instancia.buscarVendas(),

        builder: (context, snapshot) {
          // enquanto os dados estão sendo carregados,
          // exibimos um indicador de carregamento.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // se ocorrer erro, exibimos uma mensagem amigável.
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar vendas.'));
          }

          // se não houver dados, exibimos uma mensagem.
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma venda encontrada.'));
          }

          // se chegou aqui, temos uma lista de vendas.
          final vendas = snapshot.data!;

          return ListView.builder(
            // quantidade de vendas.
            itemCount: vendas.length,

            // constrói cada item da lista.
            itemBuilder: (context, indice) {
              final venda = vendas[indice];

              return ItemVenda(venda: venda);
            },
          );
        },
      ),

      // botão para cadastrar uma nova venda.
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () async {
          // abre o formulário de venda.
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FormularioVenda()),
          );

          // ao voltar do formulário, recarrega a lista.
          //
          // isso funciona tanto para SQLite quanto para API.
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }
}

// widget responsável por exibir uma venda na lista.
class ItemVenda extends StatelessWidget {
  final VendaFarmacia venda;

  const ItemVenda({super.key, required this.venda});

  @override
  Widget build(BuildContext context) {
    // formata o valor monetário no padrão brasileiro.
    final formato = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_pharmacy),

        // exibe o valor formatado.
        title: Text(formato.format(venda.valor)),

        // exibe o número do cupom.
        subtitle: Text('Nº do cupom: ${venda.numeroCupom}'),
      ),
    );
  }
}
