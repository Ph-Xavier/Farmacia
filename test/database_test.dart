// Testes do SQLite local e do controle de sincronização.
//
// usamos sqflite_common_ffi para executar o SQLite em ambiente de teste.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:farmacia/database/app_database.dart';
import 'package:farmacia/models/cliente.dart';
import 'package:farmacia/models/venda_farmacia.dart';

Future<void> _apagarBanco() async {
  final caminho = join(
    await databaseFactoryFfi.getDatabasesPath(),
    'farmacia.db',
  );

  await databaseFactoryFfi.deleteDatabase(caminho);
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(_apagarBanco);
  tearDown(_apagarBanco);

  test(
    'venda é salva como pendente e depois marcada como sincronizada',
    () async {
      final id = await salvarVenda(
        VendaFarmacia(25.50, 1234),
        sincronizado: false,
      );

      expect(id, greaterThan(0));

      var pendentes = await buscarVendasPendentes();
      expect(pendentes, hasLength(1));
      expect(pendentes.single.numeroCupom, 1234);

      await marcarVendaComoSincronizada(id);

      pendentes = await buscarVendasPendentes();
      expect(pendentes, isEmpty);

      final todas = await buscarVendas();
      expect(todas, hasLength(1));
      expect(todas.single.valor, 25.50);
    },
  );

  test(
    'cliente é salvo como pendente e depois marcado como sincronizado',
    () async {
      final id = await salvarCliente(
        Cliente(nome: 'Maria Oliveira', codigo: 4321),
        sincronizado: false,
      );

      expect(id, greaterThan(0));

      var pendentes = await buscarClientesPendentes();
      expect(pendentes, hasLength(1));
      expect(pendentes.single.nome, 'Maria Oliveira');

      await marcarClienteComoSincronizado(id);

      pendentes = await buscarClientesPendentes();
      expect(pendentes, isEmpty);
    },
  );

  test('venda salva na api é mantida localmente como sincronizada', () async {
    await salvarVenda(VendaFarmacia(10.00, 5678));

    final pendentes = await buscarVendasPendentes();
    expect(pendentes, isEmpty);

    final todas = await buscarVendas();
    expect(todas, hasLength(1));
  });
}
