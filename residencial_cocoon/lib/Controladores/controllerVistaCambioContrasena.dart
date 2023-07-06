import 'package:residencial_cocoon/Dominio/Exceptions/cambioContrasenaException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaCambioContrasena.dart';

class ControllerVistaCambioContrasena {
  //Atributos
  IvistaCambioContrasena? _vistaContrasena;

  //Constructor
  ControllerVistaCambioContrasena(this._vistaContrasena);
  ControllerVistaCambioContrasena.empty();

  //Funciones
  Future<void> cambioClave(
      String actual, String nueva, String verificacion) async {
    try {
      if (_controlDatos(nueva, verificacion)) {
        await Fachada.getInstancia()?.cambioClave(actual, nueva);
        _vistaContrasena?.mostrarMensaje("Contraseña cambiada exitosamente");
        _vistaContrasena?.limpiar();
      }
    } on CambioContrsenaException catch (ex) {
      _vistaContrasena?.mostrarMensajeError(ex.toString());
    } on TokenException catch (ex) {
      _cerrarSesion(ex.toString());
    } catch (ex) {
      _vistaContrasena?.mostrarMensajeError(ex.toString());
    }
  }

  bool _controlDatos(String nueva, String verificacion) {
    if (nueva != verificacion) {
      _vistaContrasena?.mostrarMensajeError(
          "La nueva clave tiene que ser igual en los dos campos.");
      return false;
    }
    return true;
  }

  void _cerrarSesion(String mensaje) {
    _vistaContrasena?.mostrarMensajeError(mensaje);
    _vistaContrasena?.cerrarSesion();
  }
}
