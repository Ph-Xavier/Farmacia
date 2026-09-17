import 'package:flutter/material.dart';
import 'formulario.dart';
import '../../models/transferencia.dart';
import 'package:intl/intl.dart';

class ListaTransferencias extends StatefulWidget {
  const ListaTransferencias({super.key});

  @override
  State<ListaTransferencias> createState() => ListaTransferenciasState();
}

class ListaTransferenciasState extends State<ListaTransferencias> {
  static const _tituloAppBar = "Transferências";
  final List<Transferencia> _transferencias = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tituloAppBar)),
      body: ListView.builder(
        itemCount: _transferencias.length,
        itemBuilder: (context, indice) {
          final transferencia = _transferencias[indice];
          return ItemTransferencia(transferencia: transferencia);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const FormularioTransferencia();
              },
            ),
          ).then((transferenciaRecebida) => _atualiza(transferenciaRecebida));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _atualiza(Transferencia? transferenciaRecebida) {
    if (transferenciaRecebida != null) {
      setState(() {
        _transferencias.add(transferenciaRecebida);
      });
    }
  }
}

class ItemTransferencia extends StatelessWidget {
  final Transferencia transferencia;

  const ItemTransferencia({super.key, required this.transferencia});

  @override
  Widget build(BuildContext context) {
    NumberFormat formato = NumberFormat.simpleCurrency();
    return Card(
      child: ListTile(
        leading: Icon(Icons.monetization_on),
        title: Text(formato.format(transferencia.valor).toString()),
        subtitle: Text(transferencia.numeroConta.toString()),
      ),
    );
  }
}
