import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../models/venda_farmacia.dart';
import 'configuracao_persistencia.dart';
import '../database/app_database.dart' as banco_local;
import '../services/api_service.dart';

abstract class FarmaciaRepository {
  Future<List<VendaFarmacia>> buscarVendas();

  Future<void> salvarVenda(VendaFarmacia venda);

  Future<List<Cliente>> buscarClientes();

  Future<void> salvarCliente(Cliente cliente);

  Future<void> sincronizarPendentes();

  // quantidade de registros que ainda precisam ser sincronizados.
  Future<int> contarPendentes();
}

class FarmaciaRepositoryLocal implements FarmaciaRepository {
  @override
  Future<List<VendaFarmacia>> buscarVendas() {
    return banco_local.buscarVendas();
  }

  @override
  Future<void> salvarVenda(VendaFarmacia venda) async {
    await banco_local.salvarVenda(venda);
  }

  @override
  Future<List<Cliente>> buscarClientes() {
    return banco_local.buscarClientes();
  }

  @override
  Future<void> salvarCliente(Cliente cliente) async {
    await banco_local.salvarCliente(cliente);
  }

  @override
  Future<void> sincronizarPendentes() async {
    // no modo local, não há sincronização com api.
  }

  @override
  Future<int> contarPendentes() async {
    final vendas = await banco_local.buscarVendasPendentes();
    final clientes = await banco_local.buscarClientesPendentes();

    return vendas.length + clientes.length;
  }
}

class FarmaciaRepositoryRemoto implements FarmaciaRepository {
  @override
  Future<List<VendaFarmacia>> buscarVendas() {
    return ApiService.buscarVendas();
  }

  @override
  Future<void> salvarVenda(VendaFarmacia venda) async {
    await ApiService.salvarVenda(venda);
  }

  @override
  Future<List<Cliente>> buscarClientes() {
    return ApiService.buscarClientes();
  }

  @override
  Future<void> salvarCliente(Cliente cliente) async {
    await ApiService.salvarCliente(cliente);
  }

  @override
  Future<void> sincronizarPendentes() async {
    // no modo remoto, não há pendências locais.
  }

  @override
  Future<int> contarPendentes() async {
    return 0;
  }
}

class FarmaciaRepositoryOfflineFirst implements FarmaciaRepository {
  @override
  Future<List<VendaFarmacia>> buscarVendas() async {
    try {
      final vendasRemotas = await ApiService.buscarVendas();

      // mesmo com a api disponível, exibimos também as vendas pendentes
      // que ainda não foram sincronizadas.
      final vendasPendentes = await banco_local.buscarVendasPendentes();

      return [...vendasPendentes, ...vendasRemotas];
    } catch (erro) {
      debugPrint('falha ao buscar vendas remotas: $erro');

      return banco_local.buscarVendas();
    }
  }

  @override
  Future<void> salvarVenda(VendaFarmacia venda) async {
    var sincronizado = true;

    try {
      await ApiService.salvarVenda(venda);
    } catch (erro) {
      debugPrint('falha ao salvar venda remota: $erro');
      sincronizado = false;
    }

    await banco_local.salvarVenda(venda, sincronizado: sincronizado);
  }

  @override
  Future<List<Cliente>> buscarClientes() async {
    try {
      final clientesRemotos = await ApiService.buscarClientes();

      // mesmo com a api disponível, exibimos também os clientes pendentes
      // que ainda não foram sincronizados.
      final clientesPendentes = await banco_local.buscarClientesPendentes();

      return [...clientesPendentes, ...clientesRemotos];
    } catch (erro) {
      debugPrint('falha ao buscar clientes remotos: $erro');

      return banco_local.buscarClientes();
    }
  }

  @override
  Future<void> salvarCliente(Cliente cliente) async {
    var sincronizado = true;

    try {
      await ApiService.salvarCliente(cliente);
    } catch (erro) {
      debugPrint('falha ao salvar cliente remoto: $erro');
      sincronizado = false;
    }

    await banco_local.salvarCliente(cliente, sincronizado: sincronizado);
  }

  @override
  Future<void> sincronizarPendentes() async {
    final vendasPendentes = await banco_local.buscarVendasPendentes();

    for (final venda in vendasPendentes) {
      await ApiService.salvarVenda(venda);

      if (venda.id != null) {
        await banco_local.marcarVendaComoSincronizada(venda.id!);
      }
    }

    final clientesPendentes = await banco_local.buscarClientesPendentes();

    for (final cliente in clientesPendentes) {
      await ApiService.salvarCliente(cliente);

      if (cliente.id != null) {
        await banco_local.marcarClienteComoSincronizado(cliente.id!);
      }
    }
  }

  @override
  Future<int> contarPendentes() async {
    final vendas = await banco_local.buscarVendasPendentes();
    final clientes = await banco_local.buscarClientesPendentes();

    return vendas.length + clientes.length;
  }
}

class RepositorioFarmacia {
  // permite substituir o repository em testes.
  static FarmaciaRepository? _instanciaSubstituida;

  static FarmaciaRepository get instancia {
    return _instanciaSubstituida ?? _criarInstancia();
  }

  @visibleForTesting
  static set instancia(FarmaciaRepository repository) {
    _instanciaSubstituida = repository;
  }

  @visibleForTesting
  static void restaurarInstancia() {
    _instanciaSubstituida = null;
  }

  static FarmaciaRepository _criarInstancia() {
    switch (ConfiguracaoPersistencia.origem) {
      case OrigemPersistencia.local:
        return FarmaciaRepositoryLocal();

      case OrigemPersistencia.remota:
        return FarmaciaRepositoryRemoto();

      case OrigemPersistencia.offlineFirst:
        return FarmaciaRepositoryOfflineFirst();
    }
  }
}
