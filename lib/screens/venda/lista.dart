import 'package:flutter/material.dart';
import 'formulario.dart';
import '../../models/venda_farmacia.dart';
import 'package:intl/intl.dart';

class ListaVendas extends StatefulWidget {
  const ListaVendas({super.key});

  @override
  State<ListaVendas> createState() => ListaVendasState();
}

class ListaVendasState extends State<ListaVendas> {
  static const _tituloAppBar = "Vendas";
  final List<VendaFarmacia> _vendas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tituloAppBar)),
      body: ListView.builder(
        itemCount: _vendas.length,
        itemBuilder: (context, indice) {
          final venda = _vendas[indice];
          return ItemVenda(venda: venda);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const FormularioVenda();
              },
            ),
          ).then((vendaRecebida) => _atualiza(vendaRecebida));
        },
        child: const Icon(Icons.local_pharmacy),
      ),
    );
  }

  void _atualiza(VendaFarmacia? vendaRecebida) {
    if (vendaRecebida != null) {
      setState(() {
        _vendas.add(vendaRecebida);
      });
    }
  }
}

class ItemVenda extends StatelessWidget {
  final VendaFarmacia venda;

  const ItemVenda({super.key, required this.venda});

  @override
  Widget build(BuildContext context) {
    NumberFormat formato = NumberFormat.simpleCurrency();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_pharmacy),
        title: Text(formato.format(venda.valor).toString()),
        subtitle: Text("Nº do cupom: ${venda.numeroCupom}"),
      ),
    );
  }
}