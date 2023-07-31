class AltaFamiliarException implements Exception {
  final String mensaje;

  AltaFamiliarException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
