class AltaMedicamentoException implements Exception {
  final String mensaje;

  AltaMedicamentoException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
