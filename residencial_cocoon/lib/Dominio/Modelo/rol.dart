import 'package:residencial_cocoon/Dominio/Interfaces/iRol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/cocinero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/enfermero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/nutricionista.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class Rol implements IRol {
  //Atributos
  int _idRol = 0;
  String _descripcion = "";
  Usuario _usuario = Usuario.empty();

  //Constructores
  Rol.rolTest(this._descripcion, this._usuario);

  Rol(
    this._idRol,
    this._descripcion,
    this._usuario,
  );

  Rol.id(this._idRol);

  Rol.json(this._idRol, this._descripcion);

  Rol.sinUsuario(this._idRol, this._descripcion);

  Rol.empty();

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol.json(json['id_rol'], json['descripcion']);
  }

  factory Rol.fromJsonToEspecializacion(Map<String, dynamic> json) {
    int idRol = json['id_rol'];
    String descripcion = json['descripcion'];
    switch (idRol) {
      case 1:
        return Cocinero(idRol, descripcion);
      case 2:
        return Nutricionista(idRol, descripcion);
      case 3:
        return Residente.sinFamiliares(idRol, descripcion);
      case 4:
        return Geriatra(idRol, descripcion);
      case 5:
        return Enfermero(idRol, descripcion);
      default:
        // Manejar caso de ID inválido
        throw Exception('ID de rol inválido: $idRol');
    }
  }

  //Get Set
  int get idRol => _idRol;
  set idRol(int value) => _idRol = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  Usuario get usuario => this._usuario;

  set usuario(Usuario? value) => _usuario = value!;

  String nombreUsuario() {
    return usuario.nombre;
  }

  String ciUsuario() {
    return usuario.ci;
  }

  //Funciones
  Map<String, dynamic> toIdJson() {
    return {
      'id_rol': _idRol,
    };
  }

  static List<Rol> fromJsonList(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<Rol>((json) => Rol.fromJson(json)).toList();
  }

  //Equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Rol && _idRol == other.idRol;
  }

  //Interfaz
  @override
  int get hashCode => _idRol.hashCode;

  @override
  bool esEnfermero() => false;

  @override
  bool esGeriatra() => false;

  @override
  bool esNutricionista() => false;

  @override
  bool esCocinero() => false;

  @override
  bool esResidente() {
    return false;
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "id_rol: $idRol, ";
    retorno += "descripcion: $descripcion, ";
    retorno += "usuario: ${usuario.ci} ${usuario.nombre}";
    return retorno;
  }

  String toStringMostrar() {
    return _descripcion;
  }
}
