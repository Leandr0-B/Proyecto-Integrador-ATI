import 'package:residencial_cocoon/Dominio/Exceptions/procesarControlException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/registroControlConPrescripcion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Chequeo/iVistaRegistrarControlPeriodico.dart';

class ControllerVistaRegistrarControlPeriodico {
  //Atributos
  IvistaRegistrarControlPeriodico? _vista;

  //Constructores
  ControllerVistaRegistrarControlPeriodico(this._vista);
  ControllerVistaRegistrarControlPeriodico.empty();

  //Funciones
  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }

  Future<List<RegistroControlConPrescripcion>> obtenerRegistrosControlesConPrescripcion(DateTime? fechaFiltro, String? ciFiltro) async {
    try {
      return await Fachada.getInstancia()?.obtenerRegistrosControlesConPrescripcion(fechaFiltro, ciFiltro) ?? [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  Future<void> procesarControl(RegistroControlConPrescripcion registro) async {
    try {
      if (Control.validarControles(registro.controles())) {
        await Fachada.getInstancia()?.procesarControl(registro);
      } else {
        _vista?.mostrarMensajeError("Tiene que ingresar los valores de todos los controles");
      }
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on ProcesarControlException catch (e) {
      _vista?.limpiar();
      registro.procesar();
      _vista?.cambiarColor();
      _vista?.mostrarMensaje(e.toString());
    } on Exception catch (e) {
      _vista?.mostrarMensajeError(e.toString());
    }
  }
}
