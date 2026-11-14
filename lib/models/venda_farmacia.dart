// classe que representa uma venda da farmácia.
//
// essa classe é usada tanto para:
// - persistência local com sqlite;
// - comunicação remota com a api.
class VendaFarmacia {
  // id da venda.
  //
  // o tipo int? indica que o id pode ser nulo, pois antes de salvar
  // no banco a venda ainda não possui um id gerado automaticamente.
  final int? id;

  // valor total da venda.
  final double valor;

  // número do cupom fiscal da venda.
  final int numeroCupom;

  VendaFarmacia(this.valor, this.numeroCupom, {this.id});

  // converte a venda para um Map no formato usado pelo sqlite.
  Map<String, dynamic> toMap() {
    return {'id': id, 'valor': valor, 'numero_cupom': numeroCupom};
  }

  // cria uma venda a partir de um JSON recebido da api.
  //
  // a api da farmácia retorna o campo numero_cupom.
  factory VendaFarmacia.fromJson(Map<String, dynamic> json) {
    final valor = json['valor'];
    final numeroCupom = json['numero_cupom'] ?? json['numeroCupom'];

    return VendaFarmacia(
      double.parse(valor.toString()),
      int.parse(numeroCupom.toString()),
      id: json['id'] == null ? null : int.parse(json['id'].toString()),
    );
  }

  // converte a venda para o JSON esperado pela api.
  //
  // a api da farmácia recebe o número do cupom no campo numeroCupom.
  Map<String, dynamic> toJson() {
    return {'valor': valor, 'numeroCupom': numeroCupom};
  }

  @override
  String toString() {
    return 'VendaFarmacia{id: $id, valor: $valor, numeroCupom: $numeroCupom}';
  }
}
