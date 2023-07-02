import 'package:residencial_cocoon/Dominio/Modelo/chequeoMedico.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisualizarChequeoMedico.dart';

class ControllerVistaVisualizarChequeoMedico {
  //Atributos
  IvistaVisualizarChequeoMedico? _vistaVisualizarChequeoMedico;
  //Constructor

  ControllerVistaVisualizarChequeoMedico(this._vistaVisualizarChequeoMedico);
  ControllerVistaVisualizarChequeoMedico.empty();

  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    int totalNotificaciones = await Fachada.getInstancia()?.obtenerChequeosMedicosPaginadosConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave) ?? 0;
    return (totalNotificaciones / elementosPorPagina).ceil();
  }

  Future<List<ChequeoMedico>> obtenerChequeosMedicosPaginadosConFiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await Fachada.getInstancia()?.obtenerChequeosMedicosPaginadosConFiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave) ?? [];
  }

  //Funciones
}
