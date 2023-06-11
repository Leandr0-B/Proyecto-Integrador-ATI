import 'package:residencial_cocoon/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';

class ControllerUsuario {
  //Atributos
  Function(String mensaje) mostrarMensaje;

  //Constructor
  ControllerUsuario({
    required this.mostrarMensaje,
  });

  //Funciones
  Future<Usuario?> loginUsuario(String ci, String clave) async {
    //Hace el pasamanos del login
    Usuario? usuario;
    try {
      usuario = await Fachada.getInstancia()?.login(ci, clave);
    } on LoginException catch (ex) {
      mostrarMensaje(ex.toString());
    } catch (ex) {
      mostrarMensaje(ex.toString());
    }

    return usuario;
  }

  String? _controlDatos(String ci, String clave) {
    //Controla los valores de cedula y clave
    String? respuesta;
    if (ci == "" || clave == "") {
      respuesta = "Los datos de ingreso no pueden estar vacios.";
    }
    return respuesta;
  }

  String _limpieza(String ci) {
    //Limpia los puntos y guiones de la cedula
    if (ci.contains(".")) {
      ci = ci.replaceAll(".", "");
    }
    if (ci.contains("-")) {
      ci = ci.replaceAll("-", "");
    }
    return ci;
  }
}
