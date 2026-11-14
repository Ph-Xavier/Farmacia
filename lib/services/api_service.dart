// biblioteca padrão do dart usada para converter dados em formato json.
import 'dart:convert';

// importa o pacote http, responsável por fazer requisições http.
import 'package:http/http.dart' as http;

import '../models/cliente.dart';
import '../models/venda_farmacia.dart';

// classe responsável por centralizar a comunicação com a api.
//
// a api é própria da temática farmácia (base do projeto bank) e expõe
// as rotas /vendas e /clientes.
class ApiService {
  // endereço base da api publicada no render.
  //
  // pode ser sobrescrito na execução, sem alterar o código:
  //
  // flutter run --dart-define=API_BASE_URL=https://sua-api.onrender.com
  //
  // isso facilita os testes de indisponibilidade da api.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bank-api-t311.onrender.com',
  );

  // tempo máximo de espera de cada requisição.
  //
  // se a api não responder, a operação falha e o repository salva
  // o registro localmente como pendente.
  static const Duration _timeout = Duration(seconds: 10);

  static Future<http.Response> _get(String rota) {
    return http.get(Uri.parse('$baseUrl$rota')).timeout(_timeout);
  }

  static Future<http.Response> _post(String rota, Map<String, dynamic> corpo) {
    return http
        .post(
          Uri.parse('$baseUrl$rota'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(corpo),
        )
        .timeout(_timeout);
  }

  // testa a conexão com o banco remoto.
  //
  // acessa a rota:
  // GET /teste-banco
  static Future<String> testarConexaoBanco() async {
    final resposta = await _get('/teste-banco');

    if (resposta.statusCode != 200) {
      throw Exception('erro ao testar conexão com o banco');
    }

    final dados = jsonDecode(resposta.body);

    return dados['mensagem'];
  }

  // busca as vendas na api.
  static Future<List<VendaFarmacia>> buscarVendas() async {
    final resposta = await _get('/vendas');

    if (resposta.statusCode != 200) {
      throw Exception('erro ao buscar vendas');
    }

    final dados = jsonDecode(resposta.body) as List<dynamic>;
    return dados
        .map(
          (item) =>
              VendaFarmacia.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  // envia uma nova venda para a api.
  static Future<void> salvarVenda(VendaFarmacia venda) async {
    final resposta = await _post('/vendas', venda.toJson());

    if (resposta.statusCode != 201) {
      throw Exception('erro ao salvar venda');
    }
  }

  // busca os clientes na api.
  static Future<List<Cliente>> buscarClientes() async {
    final resposta = await _get('/clientes');

    if (resposta.statusCode != 200) {
      throw Exception('erro ao buscar clientes');
    }

    final dados = jsonDecode(resposta.body) as List<dynamic>;
    return dados
        .map((item) => Cliente.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  // envia um novo cliente para a api.
  static Future<void> salvarCliente(Cliente cliente) async {
    final resposta = await _post('/clientes', cliente.toJson());

    if (resposta.statusCode != 201) {
      throw Exception('erro ao salvar cliente');
    }
  }
}
