import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';

class Enfermero extends Rol {
  //Atributos

  //Constructor
  Enfermero(int idRol, String descripcion) : super.sinUsuario(idRol, descripcion);

  Enfermero.empty() : super.empty();

  //Funciones
  @override
  bool esEnfermero() {
    return true;
  }
}
