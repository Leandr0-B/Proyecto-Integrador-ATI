import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/registroMedicacionConPrescripcion.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaVisualizarRegistroMedicacionPeriodica.dart';

class ControllerVistaVisualizarRegistroMedicacionPeriodica {
  //Atributos
  IvistaVisualizarRegistroMedicacionPeriodica? _vista;

  //Constructor
  ControllerVistaVisualizarRegistroMedicacionPeriodica.empty();
  ControllerVistaVisualizarRegistroMedicacionPeriodica(this._vista);

  //Funciones
  Future<List<RegistroMedicacionConPrescripcion>> obtenerMedicacionesPeriodicasPaginadasConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      return await Fachada.getInstancia()?.obtenerMedicacionesPeriodicasPaginadasConfiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave) ??
          [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      int totalNotificaciones = await Fachada.getInstancia()?.obtenerMedicacionesPeriodicasPaginadasConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave) ?? 0;
      return (totalNotificaciones / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }
}
