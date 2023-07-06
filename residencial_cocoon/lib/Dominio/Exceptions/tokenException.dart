class TokenException implements Exception {
  final String mensaje;

  TokenException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
