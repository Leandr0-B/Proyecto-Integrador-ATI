import 'package:residencial_cocoon/Modelo/usuario.dart';

class ServicioUsuario {
  //Atributos

  //Constructor
  ServicioUsuario() {}

  //Funciones
  Usuario? login(String ci, String clave) {
    if (ci == '52116324' && clave == '123') {
      return Usuario.login(ci, clave);
    }
    return null;
  }
}
