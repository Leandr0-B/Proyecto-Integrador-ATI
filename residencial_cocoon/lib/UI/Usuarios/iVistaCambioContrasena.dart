abstract class IvistaCambioContrasena {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiar();
  Future<void> cambioClave(String actual, String nueva, String verificacion);
  void cerrarSesion();
}
