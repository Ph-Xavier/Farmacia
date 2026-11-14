import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/venda_farmacia.dart';
import '../../repository/farmacia_repository.dart';
import '../../services/api_service.dart';

class TesteApi extends StatefulWidget {
  const TesteApi({super.key});

  @override
  State<TesteApi> createState() => _TesteApiState();
}

class _TesteApiState extends State<TesteApi> {
  String _resultado = 'nenhum teste executado ainda';
  bool _carregando = false;

  Future<void> _testarConexao() async {
    setState(() {
      _carregando = true;
      _resultado = 'testando conexão com a api...';
    });

    try {
      final mensagem = await ApiService.testarConexaoBanco();

      setState(() {
        _resultado = mensagem;
      });
    } catch (erro) {
      setState(() {
        _resultado = 'erro ao testar conexão: $erro';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _listarVendas() async {
    setState(() {
      _carregando = true;
      _resultado = 'buscando vendas...';
    });

    try {
      final vendas = await ApiService.buscarVendas();

      setState(() {
        _resultado = vendas.isEmpty
            ? 'nenhuma venda encontrada na api'
            : vendas.join('\n');
      });
    } catch (erro) {
      setState(() {
        _resultado = 'erro ao buscar vendas: $erro';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _criarVendaTeste() async {
    setState(() {
      _carregando = true;
      _resultado = 'criando venda de teste...';
    });

    try {
      final venda = VendaFarmacia(25.50, 1234);

      await ApiService.salvarVenda(venda);

      setState(() {
        _resultado = 'venda de teste criada com sucesso';
      });
    } catch (erro) {
      setState(() {
        _resultado = 'erro ao criar venda: $erro';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _listarClientes() async {
    setState(() {
      _carregando = true;
      _resultado = 'buscando clientes...';
    });

    try {
      final clientes = await ApiService.buscarClientes();

      setState(() {
        _resultado = clientes.isEmpty
            ? 'nenhum cliente encontrado na api'
            : clientes.join('\n');
      });
    } catch (erro) {
      setState(() {
        _resultado = 'erro ao buscar clientes: $erro';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _criarClienteTeste() async {
    setState(() {
      _carregando = true;
      _resultado = 'criando cliente de teste...';
    });

    try {
      final cliente = Cliente(nome: 'Cliente Flutter', codigo: 4321);

      await ApiService.salvarCliente(cliente);

      setState(() {
        _resultado = 'cliente de teste criado com sucesso';
      });
    } catch (erro) {
      setState(() {
        _resultado = 'erro ao criar cliente: $erro';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  // função responsável por enviar para a api os dados que foram
  // salvos localmente enquanto o app estava offline.
  Future<void> _sincronizarPendentes() async {
    setState(() {
      _carregando = true;
      _resultado = 'sincronizando dados pendentes...';
    });

    try {
      // chama o repository.
      //
      // se estivermos no modo offlineFirst, ele enviará os registros
      // pendentes do sqlite para a api.
      await RepositorioFarmacia.instancia.sincronizarPendentes();

      setState(() {
        _resultado = 'sincronização concluída com sucesso';
      });
    } catch (erro) {
      setState(() {
        _resultado = 'erro ao sincronizar pendentes: $erro';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste da API')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _carregando ? null : _testarConexao,
                child: const Text('Testar conexão com o banco remoto'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregando ? null : _listarVendas,
                child: const Text('Listar vendas da API'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregando ? null : _criarVendaTeste,
                child: const Text('Criar venda teste na API'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregando ? null : _listarClientes,
                child: const Text('Listar clientes da API'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregando ? null : _criarClienteTeste,
                child: const Text('Criar cliente teste na API'),
              ),
              const SizedBox(height: 24),
              if (_carregando) const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
              Text(_resultado, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregando ? null : _sincronizarPendentes,
                child: const Text('Sincronizar pendentes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
