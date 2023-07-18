class MedicacionPeriodicaException implements Exception {
  final String mensaje;

  MedicacionPeriodicaException(this.mensaje);

  @override
  String toString() {
    return mensaje;
  }
}
