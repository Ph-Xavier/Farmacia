// classe que representa um cliente da farmácia.
//
// essa classe será usada tanto para:
// - persistência local com sqlite;
// - comunicação remota com a api.
class Cliente {
  // id do cliente.
  //
  // pode ser nulo porque, antes de salvar no banco,
  // o cliente ainda não possui um id.
  final int? id;

  // nome do cliente.
  final String nome;

  // código do cliente usado no programa de fidelidade da farmácia.
  final int codigo;

  Cliente({this.id, required this.nome, required this.codigo});

  // converte o cliente para um Map no formato usado pelo sqlite.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'codigo': codigo};
  }

  // cria um cliente a partir de um JSON recebido da api.
  //
  // a api compartilhada com o projeto bank usa o campo numero_conta.
  // por isso aceitamos tanto codigo quanto numero_conta.
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] == null ? null : int.parse(json['id'].toString()),
      nome: json['nome'] as String,
      codigo: int.parse((json['codigo'] ?? json['numero_conta']).toString()),
    );
  }

  // converte o cliente para o JSON esperado pela api.
  //
  // a api da farmácia recebe o código do cliente no campo codigo.
  Map<String, dynamic> toJson() {
    return {'nome': nome, 'codigo': codigo};
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, codigo: $codigo}';
  }
}
