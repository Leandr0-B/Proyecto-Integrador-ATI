import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/salidaMedica.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisualizarSalidaMedica.dart';

class ControllerVistaVisualizarSalidaMedica {
  //Atributos
  IvistaVisualizarSalidaMedica? _vistaVisualizarSalidaMedica;
  //Constructor

  ControllerVistaVisualizarSalidaMedica(this._vistaVisualizarSalidaMedica);
  ControllerVistaVisualizarSalidaMedica.empty();

//Funciones
  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde,
      DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      int totalNotificaciones = await Fachada.getInstancia()
              ?.obtenerSalidasMedicasPaginadasConFiltrosCantidadTotal(
                  fechaDesde, fechaHasta, ciResidente, palabraClave) ??
          0;
      return (totalNotificaciones / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  Future<List<SalidaMedica>> obtenerSalidasMedicasPaginadasConFiltros(
      int paginaActual,
      int elementosPorPagina,
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      String? ciResidente,
      String? palabraClave) async {
    try {
      return await Fachada.getInstancia()
              ?.obtenerSalidasMedicasPaginadasConfiltros(
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
    _vistaVisualizarSalidaMedica?.mostrarMensajeError(mensaje);
    _vistaVisualizarSalidaMedica?.cerrarSesion();
  }
}
