import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';

class Nutricionista extends Rol {
  //Atributos

  //Constructor
  Nutricionista(int idRol, String descripcion)
      : super.sinUsuario(idRol, descripcion);

  //Funciones
  @override
  bool esNutricionista() {
    return true;
  }
}
