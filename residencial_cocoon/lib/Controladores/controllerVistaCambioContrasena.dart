import 'package:residencial_cocoon/Dominio/Exceptions/cambioContrasenaException.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaCambioContrasena.dart';

class ControllerVistaCambioContrasena {
  //Atributos
  IvistaCambioContrasena? vistaContrasena;

  //Constructor
  ControllerVistaCambioContrasena(this.vistaContrasena);
  ControllerVistaCambioContrasena.empty();

  //Funciones
  Future<void> cambioClave(
      String actual, String nueva, String verificacion) async {
    try {
      if (_controlDatos(nueva, verificacion)) {
        await Fachada.getInstancia()?.cambioClave(actual, nueva);
        vistaContrasena?.mostrarMensaje("Contraseña cambiada exitosamente");
        vistaContrasena?.limpiar();
      }
    } on CambioContrsenaException catch (ex) {
      vistaContrasena?.mostrarMensaje(ex.toString());
    } catch (ex) {
      vistaContrasena?.mostrarMensaje(ex.toString());
    }
  }

  bool _controlDatos(String nueva, String verificacion) {
    if (nueva != verificacion) {
      vistaContrasena?.mostrarMensaje(
          "La nueva clave tiene que ser igual en los dos campos.");
      return false;
    }
    return true;
  }
}
