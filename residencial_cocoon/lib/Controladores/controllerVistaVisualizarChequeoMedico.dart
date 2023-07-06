import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/chequeoMedico.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisualizarChequeoMedico.dart';

class ControllerVistaVisualizarChequeoMedico {
  //Atributos
  IvistaVisualizarChequeoMedico? _vistaVisualizarChequeoMedico;
  //Constructor

  ControllerVistaVisualizarChequeoMedico(this._vistaVisualizarChequeoMedico);
  ControllerVistaVisualizarChequeoMedico.empty();

  //Funciones
  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde,
      DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      int totalNotificaciones = await Fachada.getInstancia()
              ?.obtenerChequeosMedicosPaginadosConFiltrosCantidadTotal(
                  fechaDesde, fechaHasta, ciResidente, palabraClave) ??
          0;
      return (totalNotificaciones / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  Future<List<ChequeoMedico>> obtenerChequeosMedicosPaginadosConFiltros(
      int paginaActual,
      int elementosPorPagina,
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      String? ciResidente,
      String? palabraClave) async {
    try {
      return await Fachada.getInstancia()
              ?.obtenerChequeosMedicosPaginadosConFiltros(
                  paginaActual,
                  elementosPorPagina,
                  fechaDesde,
                  fechaHasta,
                  ciResidente,
                  palabraClave) ??
          [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  void _cerrarSesion(String mensaje) {
    _vistaVisualizarChequeoMedico?.mostrarMensajeError(mensaje);
    _vistaVisualizarChequeoMedico?.cerrarSesion();
  }
}
