class PrescripcionStockException implements Exception {
  final String mensaje;

  PrescripcionStockException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
