class AsociarMedicamentoException implements Exception {
  final String mensaje;

  AsociarMedicamentoException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
