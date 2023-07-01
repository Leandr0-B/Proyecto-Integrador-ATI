import 'package:residencial_cocoon/Dominio/Modelo/salidaMedica.dart';
import 'package:residencial_cocoon/Dominio/Modelo/visitaMedicaExterna.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisualizarVisitaMedicaExterna.dart';

class ControllerVistaVisualizarVisitaMedicaExterna {
  //Atributos
  IvistaVisualizarVisitaMedicaExterna? _vistaVisualizarVisitaMedicaExterna;
  //Constructor

  ControllerVistaVisualizarVisitaMedicaExterna(this._vistaVisualizarVisitaMedicaExterna);
  ControllerVistaVisualizarVisitaMedicaExterna.empty();

  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    int totalNotificaciones = await Fachada.getInstancia()?.obtenerVisitasMedicasExternasPaginadasConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave) ?? 0;
    return (totalNotificaciones / elementosPorPagina).ceil();
  }

  Future<List<VisitaMedicaExterna>> obtenerVisitasMedicasExternasPaginadasConFiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await Fachada.getInstancia()?.obtenerVisitasMedicasExternasPaginadasConFiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave) ??
        [];
  }

  //Funciones
}
