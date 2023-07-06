import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/visitaMedicaExterna.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisualizarVisitaMedicaExterna.dart';

class ControllerVistaVisualizarVisitaMedicaExterna {
  //Atributos
  IvistaVisualizarVisitaMedicaExterna? _vistaVisualizarVisitaMedicaExterna;
  //Constructor

  ControllerVistaVisualizarVisitaMedicaExterna(
      this._vistaVisualizarVisitaMedicaExterna);
  ControllerVistaVisualizarVisitaMedicaExterna.empty();

//Funciones
  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde,
      DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      int totalNotificaciones = await Fachada.getInstancia()
              ?.obtenerVisitasMedicasExternasPaginadasConFiltrosCantidadTotal(
                  fechaDesde, fechaHasta, ciResidente, palabraClave) ??
          0;
      return (totalNotificaciones / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  Future<List<VisitaMedicaExterna>>
      obtenerVisitasMedicasExternasPaginadasConFiltros(
          int paginaActual,
          int elementosPorPagina,
          DateTime? fechaDesde,
          DateTime? fechaHasta,
          String? ciResidente,
          String? palabraClave) async {
    try {
      return await Fachada.getInstancia()
              ?.obtenerVisitasMedicasExternasPaginadasConFiltros(
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
    _vistaVisualizarVisitaMedicaExterna?.mostrarMensajeError(mensaje);
    _vistaVisualizarVisitaMedicaExterna?.cerrarSesion();
  }
}
