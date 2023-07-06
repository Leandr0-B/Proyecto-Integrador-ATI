import 'package:residencial_cocoon/Dominio/Modelo/visitaMedicaExterna.dart';

abstract class IvistaVisualizarVisitaMedicaExterna {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiarFiltros();
  void obtenerVisitaMedicaExternaPaginadasBotonFiltrar();
  void obtenerVisitaMedicaExternaPaginadasConfiltros();
  void obtenerVisitaMedicaExternaPaginadas();
  void mostrarPopUp(VisitaMedicaExterna visitaMedicaExterna);
  void cerrarSesion();
}
