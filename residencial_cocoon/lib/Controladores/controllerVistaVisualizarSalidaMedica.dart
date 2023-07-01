import 'package:residencial_cocoon/Dominio/Exceptions/salidaMedicaException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/salidaMedica.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisualizarSalidaMedica.dart';

class ControllerVistaVisualizarSalidaMedica {
  //Atributos
  IvistaVisualizarSalidaMedica? _vistaVisualizarSalidaMedica;
  //Constructor

  ControllerVistaVisualizarSalidaMedica(this._vistaVisualizarSalidaMedica);
  ControllerVistaVisualizarSalidaMedica.empty();

  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    int totalNotificaciones = await Fachada.getInstancia()?.obtenerSalidasMedicasPaginadasConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave) ?? 0;
    return (totalNotificaciones / elementosPorPagina).ceil();
  }

  Future<List<SalidaMedica>> obtenerSalidasMedicasPaginadasConFiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await Fachada.getInstancia()?.obtenerSalidasMedicasPaginadasConfiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave) ?? [];
  }

  //Funciones
}
