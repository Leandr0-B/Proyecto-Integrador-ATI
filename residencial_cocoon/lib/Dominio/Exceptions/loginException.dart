class LoginException implements Exception {
  final String mensaje;

  LoginException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
