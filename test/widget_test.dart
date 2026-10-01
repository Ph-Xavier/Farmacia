// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmacia/main.dart';

void main() {
  testWidgets('creates and lists a venda', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VendaFarmaciaApp());

    expect(find.text('Vendas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.local_pharmacy));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1234');
    await tester.enterText(find.byType(TextField).at(1), '12.50');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('12,50'), findsOneWidget);
    expect(find.text('Nº do cupom: 1234'), findsOneWidget);
  });
}