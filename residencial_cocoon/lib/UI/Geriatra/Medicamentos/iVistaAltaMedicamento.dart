abstract class IvistaAltaMedicamento {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiar();
  Future<void> altaMedicamento();
  void cerrarSesion();
}
