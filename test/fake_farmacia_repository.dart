import 'package:farmacia/models/cliente.dart';
import 'package:farmacia/models/venda_farmacia.dart';
import 'package:farmacia/repository/farmacia_repository.dart';

// repository falso utilizado nos testes de interface.
class FakeFarmaciaRepository implements FarmaciaRepository {
  FakeFarmaciaRepository({this.pendentes = 0});

  int pendentes;
  bool sincronizou = false;
  bool falharSincronizacao = false;

  final List<VendaFarmacia> vendas = [];
  final List<Cliente> clientes = [];

  @override
  Future<int> contarPendentes() async {
    return pendentes;
  }

  @override
  Future<void> sincronizarPendentes() async {
    if (falharSincronizacao) {
      throw Exception('falha simulada');
    }

    sincronizou = true;
    pendentes = 0;
  }

  @override
  Future<List<VendaFarmacia>> buscarVendas() async {
    return vendas;
  }

  @override
  Future<void> salvarVenda(VendaFarmacia venda) async {
    vendas.add(venda);
  }

  @override
  Future<List<Cliente>> buscarClientes() async {
    return clientes;
  }

  @override
  Future<void> salvarCliente(Cliente cliente) async {
    clientes.add(cliente);
  }
}
