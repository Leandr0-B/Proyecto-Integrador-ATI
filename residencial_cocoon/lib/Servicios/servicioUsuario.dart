import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'dart:convert';

class ServicioUsuario {
  //Atributos

  //Constructor
  ServicioUsuario();

  //Funciones
  // Usuario? login(String ci, String clave) {
  //   //if (Usuario.validarCi() && Usuario.validarClave()) {
  //   APIService.fetchAuth(ci, clave).then((usuario) {
  //     print('usuario: $usuario');
  //   });
  //   //}

  //   // if (ci == '52116324' && clave == '123') {
  //   //   return Usuario.login(ci, clave);
  //   // }
  //   return null;
  // }

  Future<Usuario?> login(String ci, String clave) async {
    // validar la CI y la Clave
    String usuario = await APIService.fetchAuth(ci, clave);
    Map<String, dynamic> jsonMap = jsonDecode(usuario);
    return Usuario.fromJson(jsonMap);
  }
}
