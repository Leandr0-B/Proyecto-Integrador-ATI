import 'package:residencial_cocoon/Dominio/Exceptions/altaMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaAltaMedicamento.dart';

class ControllerVistaAltaMedicamento {
  //Atributos
  IvistaAltaMedicamento? _vista;

  //Constructor
  ControllerVistaAltaMedicamento.empty();
  ControllerVistaAltaMedicamento(this._vista);

  //Funciones
  Future<void> altaMedicamento(String nombre, String? unidad) async {
    if (_controles(unidad)) {
      try {
        await Fachada?.getInstancia()?.altaMedicamento(nombre, unidad);
      } on AltaMedicamentoException catch (e) {
        _vista?.mostrarMensaje(e.toString());
        _vista?.limpiar();
      } on TokenException catch (e) {
        _cerrarSesion(e.toString());
      } on Exception catch (ex) {
        _vista?.mostrarMensajeError(ex.toString());
      }
    }
  }

  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }

  bool _controles(String? uniadad) {
    if (uniadad == null || uniadad.isEmpty) {
      _vista?.mostrarMensajeError("Tiene que seleccionar la unidad del medicamento");
      return false;
    }
    return true;
  }
}
