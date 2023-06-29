class ChequeoMedicoException implements Exception {
  final String mensaje;

  ChequeoMedicoException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
