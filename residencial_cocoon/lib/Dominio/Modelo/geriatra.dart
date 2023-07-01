import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';

class Geriatra extends Rol {
  //Atributos

  //Constructor
  Geriatra(int idRol, String descripcion) : super.sinUsuario(idRol, descripcion);

  Geriatra.empty() : super.empty();
  //Funciones
  @override
  bool esGeriatra() {
    return true;
  }
}
