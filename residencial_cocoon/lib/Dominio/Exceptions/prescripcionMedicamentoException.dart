class PrescripcionMedicamentoException implements Exception {
  final String mensaje;

  PrescripcionMedicamentoException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
