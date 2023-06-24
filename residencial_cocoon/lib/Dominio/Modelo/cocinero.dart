import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';

class Cocinero extends Rol {
  //Atributos

  //Constructor
  Cocinero(int idRol, String descripcion)
      : super.sinUsuario(idRol, descripcion);

  //Funciones
  @override
  bool esCocinero() {
    return true;
  }
}
