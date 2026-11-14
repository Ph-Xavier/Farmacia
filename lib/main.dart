import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database/app_database.dart';
import './screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';

  // verifica o banco local na inicialização.
  //
  // usamos try/catch para que uma falha na verificação (por exemplo,
  // em plataformas sem suporte ao sqflite) não impeça o app de abrir.
  try {
    await testeBanco();
  } catch (erro) {
    debugPrint('não foi possível verificar o banco local: $erro');
  }

  runApp(const VendaFarmaciaApp());
}

class VendaFarmaciaApp extends StatelessWidget {
  const VendaFarmaciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Ativa o estilo Material 3.
        useMaterial3: true,

        // Define uma paleta de cores a partir de uma cor base.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

        // Define a cor principal do aplicativo.
        primaryColor: Colors.blue.shade900,

        // Tema para a AppBar.
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Tema para botões elevados.
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

        // Tema para o FloatingActionButton.
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),

        // Tema para campos de texto.
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),

      home: const Dashboard(),
    );
  }
}
