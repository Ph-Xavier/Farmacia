// Testes do aplicativo da farmácia.
//
// Aqui verificamos o dashboard, a sincronização manual e a conversão
// dos models usados pela persistência local e pela api.

import 'package:flutter_test/flutter_test.dart';

import 'package:farmacia/main.dart';
import 'package:farmacia/models/cliente.dart';
import 'package:farmacia/models/venda_farmacia.dart';
import 'package:farmacia/repository/farmacia_repository.dart';

import 'fake_farmacia_repository.dart';

void main() {
  late FakeFarmaciaRepository repository;

  setUp(() {
    repository = FakeFarmaciaRepository(pendentes: 2);
    RepositorioFarmacia.instancia = repository;
  });

  tearDown(() {
    RepositorioFarmacia.restaurarInstancia();
  });

  testWidgets('renderiza o dashboard com as ações do app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VendaFarmaciaApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Vendas'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Teste API'), findsOneWidget);
    expect(
      find.text('2 registro(s) pendente(s) de sincronização.'),
      findsOneWidget,
    );
    expect(find.text('Sincronizar pendentes'), findsOneWidget);
  });

  testWidgets('sincroniza os registros pendentes pelo dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VendaFarmaciaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sincronizar pendentes'));
    await tester.pumpAndSettle();

    expect(repository.sincronizou, isTrue);
    expect(
      find.text('Nenhum registro pendente de sincronização.'),
      findsOneWidget,
    );

    // aguarda o SnackBar desaparecer para não deixar timers pendentes.
    await tester.pump(const Duration(seconds: 5));
  });

  test('converte venda para Map e JSON', () {
    final venda = VendaFarmacia(12.50, 1234);

    expect(venda.toMap(), {'id': null, 'valor': 12.50, 'numero_cupom': 1234});

    expect(venda.toJson(), {'valor': 12.50, 'numeroCupom': 1234});
  });

  test('cria venda a partir do JSON da api da farmácia', () {
    final venda = VendaFarmacia.fromJson({
      'id': 6,
      'valor': '25.50',
      'numero_cupom': 1234,
    });

    expect(venda.id, 6);
    expect(venda.valor, 25.50);
    expect(venda.numeroCupom, 1234);
  });

  test('aceita venda no formato antigo da api bank', () {
    final venda = VendaFarmacia.fromJson({
      'id': 1,
      'valor': '150.75',
      'numero_conta': 1234,
    });

    expect(venda.valor, 150.75);
    expect(venda.numeroCupom, 1234);
  });

  test('converte cliente para Map e JSON', () {
    final cliente = Cliente(nome: 'Maria Oliveira', codigo: 4321);

    expect(cliente.toMap(), {
      'id': null,
      'nome': 'Maria Oliveira',
      'codigo': 4321,
    });

    expect(cliente.toJson(), {'nome': 'Maria Oliveira', 'codigo': 4321});
  });

  test('cria cliente a partir do JSON da api da farmácia', () {
    final cliente = Cliente.fromJson({
      'id': 1,
      'nome': 'Maria Oliveira',
      'codigo': 4321,
    });

    expect(cliente.id, 1);
    expect(cliente.nome, 'Maria Oliveira');
    expect(cliente.codigo, 4321);
  });
}
