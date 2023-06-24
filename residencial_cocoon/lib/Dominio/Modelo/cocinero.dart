import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class Cocinero extends Rol {
  //Atributos

  //Constructor
  Cocinero({required int idRol, required String descripcion, required usuario})
      : super(idRol: idRol, descripcion: descripcion, usuario: usuario);

  //Funciones
  @override
  bool esResidente() {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id_rol': idRol,
      'descripcion': descripcion,
      'usuario': usuario,
    };
  }
}
