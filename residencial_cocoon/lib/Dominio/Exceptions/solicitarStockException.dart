class SolicitarStockException implements Exception {
  final String mensaje;

  SolicitarStockException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
