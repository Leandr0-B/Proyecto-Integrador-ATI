class CambioContrsenaException implements Exception {
  final String mensaje;

  CambioContrsenaException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
