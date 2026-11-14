import 'package:flutter/material.dart';

import './clientes/lista_clientes.dart';
import './venda/lista.dart';
import '../repository/farmacia_repository.dart';
import '../testes/teste_api.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // quantidade de registros pendentes de sincronização.
  int _pendentes = 0;

  // indica se a contagem inicial ainda está sendo carregada.
  bool _carregandoPendentes = true;

  // indica se a sincronização está em andamento.
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _atualizarPendentes();
  }

  // consulta no repository quantos registros estão pendentes.
  Future<void> _atualizarPendentes() async {
    try {
      final total = await RepositorioFarmacia.instancia.contarPendentes();

      if (!mounted) return;

      setState(() {
        _pendentes = total;
        _carregandoPendentes = false;
      });
    } catch (erro) {
      debugPrint('erro ao contar pendentes: $erro');

      if (!mounted) return;

      setState(() {
        _carregandoPendentes = false;
      });
    }
  }

  // envia para a api todos os registros pendentes.
  Future<void> _sincronizar() async {
    setState(() {
      _sincronizando = true;
    });

    try {
      await RepositorioFarmacia.instancia.sincronizarPendentes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronização concluída com sucesso.')),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sincronizar pendentes: $erro')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sincronizando = false;
        });
      }

      _atualizarPendentes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            // alinhamento horizontal.
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              // cabeçalho do dashboard.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_pharmacy,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Farmácia',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // painel de sincronização manual.
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _carregandoPendentes
                                  ? 'Verificando registros pendentes...'
                                  : _pendentes == 0
                                  ? 'Nenhum registro pendente de sincronização.'
                                  : '$_pendentes registro(s) pendente(s) de sincronização.',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _sincronizando ? null : _sincronizar,
                        icon: _sincronizando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(
                          _sincronizando
                              ? 'Sincronizando...'
                              : 'Sincronizar pendentes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8.0),

              // o widget Wrap organiza os elementos em linhas e permite
              // quebra automática quando não há espaço suficiente.
              Wrap(
                // espaçamento horizontal entre os itens.
                spacing: 12,

                // espaçamento vertical entre as linhas.
                runSpacing: 12,

                children: [
                  // primeiro card: acesso à tela de vendas.
                  _FeatureItem(
                    nome: 'Vendas',
                    icone: Icons.local_pharmacy,
                    onClick: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => const ListaVendas(),
                            ),
                          )
                          .then((_) => _atualizarPendentes());
                    },
                  ),

                  // segundo card: acesso à tela de clientes.
                  _FeatureItem(
                    nome: 'Clientes',
                    icone: Icons.people,
                    onClick: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => const ListaClientes(),
                            ),
                          )
                          .then((_) => _atualizarPendentes());
                    },
                  ),

                  // terceiro card: acesso à tela de testes da api.
                  _FeatureItem(
                    nome: 'Teste API',
                    icone: Icons.cloud,
                    onClick: () {
                      // abre a tela TesteApi, usada para testar a comunicação
                      // entre flutter, api no render e postgresql.
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => const TesteApi(),
                            ),
                          )
                          .then((_) => _atualizarPendentes());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String nome;
  final IconData icone;
  final void Function() onClick;

  const _FeatureItem({
    required this.nome,
    required this.icone,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),

      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),

        child: Container(
          height: 120,
          width: 120,
          padding: const EdgeInsets.all(8),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
