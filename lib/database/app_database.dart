// pacote "path" fornece utilitários para manipular caminhos de arquivos.
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

// pacote sqflite: API para trabalhar com SQLite em Flutter/Dart.
import 'package:sqflite/sqflite.dart';

import '../models/cliente.dart';
import '../models/venda_farmacia.dart';

import 'dart:io';

// abre (ou cria) o banco de dados local da farmácia.
Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'farmacia.db');

  return openDatabase(
    path,
    onCreate: (db, version) async {
      // tabela de vendas.
      await db.execute(
        'CREATE TABLE vendas('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'valor REAL, '
        'numero_cupom INTEGER, '
        'sincronizado INTEGER NOT NULL DEFAULT 1)',
      );

      // tabela de clientes.
      await db.execute(
        'CREATE TABLE clientes('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'nome TEXT, '
        'codigo INTEGER, '
        'sincronizado INTEGER NOT NULL DEFAULT 1)',
      );
    },
    version: 1,
  );
}

// função responsável por salvar um cliente no sqlite.
//
// o parâmetro sincronizado indica se o cliente já foi enviado
// para a api ou se ainda está pendente.
Future<int> salvarCliente(Cliente cliente, {bool sincronizado = true}) async {
  final Database db = await getDatabase();

  // reaproveitamos o toMap() do model Cliente.
  final Map<String, dynamic> clienteMap = cliente.toMap();

  // adicionamos a informação de sincronização ao map.
  clienteMap['sincronizado'] = sincronizado ? 1 : 0;

  return db.insert('clientes', clienteMap);
}

// busca todos os clientes salvos localmente.
Future<List<Cliente>> buscarClientes() async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> resultado = await db.query('clientes');

  return List.generate(resultado.length, (i) {
    return Cliente(
      id: resultado[i]['id'],
      nome: resultado[i]['nome'],
      codigo: resultado[i]['codigo'],
    );
  });
}

// busca apenas os clientes que ainda não foram sincronizados.
//
// sincronizado = 0 significa que o cliente está pendente.
Future<List<Cliente>> buscarClientesPendentes() async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> resultado = await db.query(
    'clientes',
    where: 'sincronizado = ?',
    whereArgs: [0],
  );

  return List.generate(resultado.length, (i) {
    return Cliente(
      id: resultado[i]['id'],
      nome: resultado[i]['nome'],
      codigo: resultado[i]['codigo'],
    );
  });
}

// marca um cliente local como sincronizado.
//
// essa função é chamada depois que o cliente pendente
// for enviado com sucesso para a api.
Future<int> marcarClienteComoSincronizado(int id) async {
  final Database db = await getDatabase();

  return db.update(
    'clientes',
    {'sincronizado': 1},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// função responsável por salvar uma venda no sqlite.
//
// o parâmetro sincronizado indica se a venda já foi enviada
// para a api ou se ainda está pendente.
Future<int> salvarVenda(VendaFarmacia venda, {bool sincronizado = true}) async {
  final Database db = await getDatabase();

  final Map<String, dynamic> vendaMap = {
    'valor': venda.valor,
    'numero_cupom': venda.numeroCupom,

    // sqlite não possui boolean puro.
    // por isso, salvamos:
    // true  → 1
    // false → 0
    'sincronizado': sincronizado ? 1 : 0,
  };

  return db.insert('vendas', vendaMap);
}

// busca todas as vendas salvas localmente.
Future<List<VendaFarmacia>> buscarVendas() async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> resultado = await db.query('vendas');

  return List.generate(resultado.length, (i) {
    return VendaFarmacia(
      resultado[i]['valor'],
      resultado[i]['numero_cupom'],

      // agora também trazemos o id local.
      id: resultado[i]['id'],
    );
  });
}

// busca apenas as vendas que ainda não foram sincronizadas.
//
// sincronizado = 0 significa que o registro está pendente.
Future<List<VendaFarmacia>> buscarVendasPendentes() async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> resultado = await db.query(
    'vendas',
    where: 'sincronizado = ?',
    whereArgs: [0],
  );

  return List.generate(resultado.length, (i) {
    return VendaFarmacia(
      resultado[i]['valor'],
      resultado[i]['numero_cupom'],
      id: resultado[i]['id'],
    );
  });
}

// marca uma venda local como sincronizada.
//
// essa função é chamada depois que a venda pendente
// for enviada com sucesso para a api.
Future<int> marcarVendaComoSincronizada(int id) async {
  final Database db = await getDatabase();

  return db.update(
    'vendas',

    // atualiza o campo sincronizado para 1.
    {'sincronizado': 1},

    // atualiza apenas o registro com o id informado.
    where: 'id = ?',
    whereArgs: [id],
  );
}

// função de apoio usada na inicialização do app para verificar
// se o arquivo do banco local existe e quais tabelas ele possui.
Future<void> testeBanco() async {
  final String path = join(await getDatabasesPath(), 'farmacia.db');
  final File arquivoBanco = File(path);

  final bool existe = await arquivoBanco.exists();

  if (existe) {
    debugPrint('****Banco de dados encontrado: $path');
    final Database db = await openDatabase(path);

    final List<Map<String, dynamic>> tabelas = await db.rawQuery(
      "select name from sqlite_master where type = 'table';",
    );

    if (tabelas.isNotEmpty) {
      debugPrint('****Tabelas encontradas:');
      for (var tabela in tabelas) {
        debugPrint('- ${tabela['name']}');
      }
    } else {
      debugPrint('****Nenhuma tabela encontrada no banco.');
    }
    await db.close();
  } else {
    debugPrint(
      'XXXX - O arquivo do banco de dados não foi encontrado em: $path',
    );
  }
}
