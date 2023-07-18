import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/Medicamentos/iVistaVisualizarPrescripcionMedicamento.dart';

class ControllerVistaVisualizarPrescripcionMedicamento {
  //Atributos
  IvistaVisualizarPrescripcionMedicamento? _vista;

  //Constructor
  ControllerVistaVisualizarPrescripcionMedicamento.empty();
  ControllerVistaVisualizarPrescripcionMedicamento(this._vista);

  //Funciones
  Future<List<PrescripcionDeMedicamento>> obtenerPrescripcionesMedicamentosPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      return await Fachada.getInstancia()
              ?.obtenerPrescripcionesMedicamentosPaginadosConfiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave) ??
          [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  Future<int> calcularTotalPaginas(int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    try {
      int totalPrescripciones =
          await Fachada.getInstancia()?.obtenerPrescripcionesMedicamentosPaginadosConfiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave) ?? 0;
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
