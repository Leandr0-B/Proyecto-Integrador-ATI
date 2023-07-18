import 'package:residencial_cocoon/Dominio/Modelo/chequeoMedico.dart';

abstract class IvistaVisualizarPrescripcionMedicamento {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiarFiltros();
  void cerrarSesion();
}
