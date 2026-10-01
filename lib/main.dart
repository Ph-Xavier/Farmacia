import 'package:flutter/material.dart';
import 'package:farmacia/screens/venda/lista.dart';
import 'package:intl/intl.dart';

void main() => runApp(const VendaFarmaciaApp());

class VendaFarmaciaApp extends StatelessWidget {
  const VendaFarmaciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = "pt_BR";
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        primaryColor: Colors.blue.shade900,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ListaVendas(),
    );
  }
}