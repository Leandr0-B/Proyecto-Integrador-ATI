import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/prescripcionDeControl.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Chequeo/iVistaVisualizarPrescripcionesControl.dart';

class ControllerVistaVisualizarPrescripcionesControl {
  //Atributos
  IvistaVisualizarPrescripcionesControl? _vista;

  //Constructores
  ControllerVistaVisualizarPrescripcionesControl.empty();
  ControllerVistaVisualizarPrescripcionesControl(this._vista);

  //Funciones
  Future<List<PrescripcionDeControl>> obtenerPrescripcionesControlesPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      return await Fachada.getInstancia()?.obtenerPrescripcionesControlesPaginadosConfiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave) ??
          [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      int totalPrescripciones =
          await Fachada.getInstancia()?.obtenerPrescripcionesControlesPaginadosConfiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave) ?? 0;
      return (totalPrescripciones / elementosPorPagina).ceil();
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
