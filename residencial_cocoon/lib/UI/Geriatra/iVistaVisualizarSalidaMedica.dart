import 'package:residencial_cocoon/Dominio/Modelo/salidaMedica.dart';

abstract class IvistaVisualizarSalidaMedica {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiarFiltros();
  void obtenerSalidasMedicasPaginadasBotonFiltrar();
  void obtenerSalidasMedicasPaginadasConfiltros();
  void obtenerSalidasMedicasPaginadas();
  void mostrarPopUp(SalidaMedica salidaMedica);
  void cerrarSesion();
}
