import 'package:residencial_cocoon/Dominio/Modelo/chequeoMedico.dart';

abstract class IvistaVisualizarChequeoMedico {
  void mostrarMensaje(String mensaje);
  void limpiarFiltros();
  void obtenerChequeosMedicosPaginadosBotonFiltrar();
  void obtenerChequeosMedicosPaginadosConfiltros();
  void obtenerChequeosMedicosPaginados();
  void mostrarPopUp(ChequeoMedico chequeoMedico);
}
