class VendaFarmacia {
  final double valor;
  final int numeroCupom;

  VendaFarmacia(this.valor, this.numeroCupom);

  @override
  String toString() {
    return "VendaFarmacia{valor: $valor, numeroCupom: $numeroCupom}";
  }
}