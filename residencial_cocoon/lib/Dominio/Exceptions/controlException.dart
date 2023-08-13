class ControlException implements Exception {
  final String mensaje;

  ControlException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
