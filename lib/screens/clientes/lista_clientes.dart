import 'package:flutter/material.dart';

import 'formulario_cliente.dart';
import '../../models/cliente.dart';
import '../../repository/farmacia_repository.dart';

class ListaClientes extends StatefulWidget {
  const ListaClientes({super.key});

  @override
  State<ListaClientes> createState() => _ListaClientesState();
}

class _ListaClientesState extends State<ListaClientes> {
  static const _tituloAppBar = 'Clientes';

  final List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _carregarClientesDoBanco();
  }

  // busca os clientes no repository.
  //
  // o repository decide se busca no SQLite ou na API.
  void _carregarClientesDoBanco() async {
    try {
      final clientes = await RepositorioFarmacia.instancia.buscarClientes();

      if (!mounted) return;

      setState(() {
        _clientes
          ..clear()
          ..addAll(clientes);
      });
    } catch (erro) {
      debugPrint('erro ao carregar clientes: $erro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_tituloAppBar)),

      body: _clientes.isEmpty
          ? const Center(child: Text('Nenhum cliente encontrado.'))
          : ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final cliente = _clientes[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(cliente.nome),
                    subtitle: Text('Código: ${cliente.codigo}'),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // abre o formulário de cliente.
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularioCliente()),
          );

          // ao voltar do formulário, recarrega a lista.
          _carregarClientesDoBanco();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
