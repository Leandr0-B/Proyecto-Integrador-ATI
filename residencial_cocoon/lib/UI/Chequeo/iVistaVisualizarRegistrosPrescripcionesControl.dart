import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaVisualizarRegistrosPrescripcionesControl {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiarFiltros();
  void cerrarSesion();
}
