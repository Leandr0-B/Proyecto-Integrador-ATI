import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class Residente extends Rol {
  //Atributos
  //List<Familiar> _familiares;

  //Constructor
  Residente(
      {required int idRol,
      required String descripcion,
      required Usuario usuario})
      : super(idRol: idRol, descripcion: descripcion, usuario: usuario);

  //Funciones
  @override
  bool esResidente() {
    return true;
  }
/*
  @override
  List<Familiar> getFamiliares() {
    return _familiares;
  }

  @override
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> familiaresJson =
        _familiares!.map((familiar) => familiar.toJson()).toList();
    return {
      'id_rol': idRol,
      'descripcion': descripcion,
      'usuario': usuario,
      'familiares': familiaresJson,
    };
  }
  */
}
