class SalidaMedicaException implements Exception {
  final String mensaje;

  SalidaMedicaException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
