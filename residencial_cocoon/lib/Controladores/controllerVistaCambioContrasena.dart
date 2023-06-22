import 'package:residencial_cocoon/Dominio/Exceptions/cambioContrasenaException.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaCambioContrasena {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  Function() limpiar;

  //Constructor
  ControllerVistaCambioContrasena({
    required this.mostrarMensaje,
    required this.limpiar,
  });

  //Funciones
  Future<void> cambioClave(
      String actual, String nueva, String verificacion) async {
    try {
      if (_controlDatos(nueva, verificacion)) {
        await Fachada.getInstancia()?.cambioClave(actual, nueva);
        mostrarMensaje("Contraseña cambiada exitosamente");
        limpiar();
      }
    } on CambioContrsenaException catch (ex) {
      mostrarMensaje(ex.toString());
    } catch (ex) {
      mostrarMensaje(ex.toString());
    }
  }

  bool _controlDatos(String nueva, String verificacion) {
    if (nueva != verificacion) {
      mostrarMensaje("La nueva clave tiene que ser igual en los dos campos.");
      return false;
    }
    return true;
  }
}
