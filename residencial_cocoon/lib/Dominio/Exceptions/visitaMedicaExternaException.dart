class visitaMedicaExternaException implements Exception {
  final String mensaje;

  visitaMedicaExternaException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
