import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

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
      Fachada.getInstancia()?.setUsuario(usuario);
      _guardarUsuarioEnLocalStorage(usuario);
    } on LoginException catch (ex) {
      mostrarMensaje(ex.toString());
    } catch (ex) {
      mostrarMensaje(ex.toString());
    }
    return usuario;
  }

  void _guardarUsuarioEnLocalStorage(Usuario? usuario) {
    final jsonData = {'authToken': usuario?.getToken()};

    final jsonString = json.encode(jsonData);
    html.window.localStorage['usuario'] = jsonString;
  }
}
