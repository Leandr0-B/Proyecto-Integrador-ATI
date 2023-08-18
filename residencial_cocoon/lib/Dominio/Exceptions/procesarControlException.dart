class ProcesarControlException implements Exception {
  final String mensaje;

  ProcesarControlException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
