import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';
import 'package:residencial_cocoon/UI/Login/iVistaLogin.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class ControllerVistaLogin {
  //Atributos
  IVistaLogin? _vistaLogin;

  //Constructor
  ControllerVistaLogin.empty();
  ControllerVistaLogin(this._vistaLogin);

  //Funciones
  Future<void> loginUsuario(String ci, String clave) async {
    //Hace el pasamanos del login
    Usuario? usuario;
    try {
      usuario = await Fachada.getInstancia()?.login(ci, clave);
      Fachada.getInstancia()?.setUsuario(usuario);
      _guardarUsuarioEnLocalStorage(usuario);
      _vistaLogin?.ingreso(usuario);
    } on LoginException catch (ex) {
      _vistaLogin?.mostrarMensaje(ex.toString());
    } catch (ex) {
      _vistaLogin?.mostrarMensaje(ex.toString());
    }
  }

  void _guardarUsuarioEnLocalStorage(Usuario? usuario) {
    final jsonData = {'authToken': usuario?.getToken()};

    final jsonString = json.encode(jsonData);
    html.window.localStorage['usuario'] = jsonString;
  }
}
