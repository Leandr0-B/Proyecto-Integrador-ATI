class AltaUsuarioException implements Exception {
  final String mensaje;

  AltaUsuarioException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
