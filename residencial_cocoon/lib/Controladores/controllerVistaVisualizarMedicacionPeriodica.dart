import 'package:residencial_cocoon/Dominio/Exceptions/medicacionPeriodicaException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/registroMedicacionConPrescripcion.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaRegistrarMedicacionPeriodica.dart';

class ControllerVistaRegistrarMedicacionPeriodica {
  //Atributos
  IvistaRegistrarMedicacionPeriodica? _vista;

  //Constructor
  ControllerVistaRegistrarMedicacionPeriodica(this._vista);
  ControllerVistaRegistrarMedicacionPeriodica.empty();

  //Funciones

  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }

  Future<List<RegistroMedicacionConPrescripcion>> obtenerRegistrosMedicamentosConPrescripcion(DateTime? fechaFiltro, String? ciFiltro) async {
    try {
      return await Fachada.getInstancia()?.obtenerRegistrosMedicamentosConPrescripcion(fechaFiltro, ciFiltro) ?? [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  Future<void> procesarMedicacion(RegistroMedicacionConPrescripcion? selectedRegistro) async {
    try {
      await Fachada.getInstancia()?.procesarMedicacion(selectedRegistro);
    } on MedicacionPeriodicaException catch (e) {
      _vista?.limpiar();
      _vista?.cambiarColor(selectedRegistro);
      _vista?.mostrarMensaje(e.toString());
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on Exception catch (e) {
      _vista?.mostrarMensajeError(e.toString());
    }
  }
}
