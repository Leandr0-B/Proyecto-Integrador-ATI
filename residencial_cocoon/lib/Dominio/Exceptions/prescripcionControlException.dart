class PrescripcionControlException implements Exception {
  final String mensaje;

  PrescripcionControlException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
