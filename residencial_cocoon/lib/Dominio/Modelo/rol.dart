import 'package:residencial_cocoon/Dominio/Interfaces/iRol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class Rol implements IRol {
  //Atributos
  int _idRol = 0;
  String _descripcion = "";
  Usuario? _usuario;

  //Constructores
  Rol.usuarioTest(this._usuario);
  Rol({
    required int idRol,
    required String descripcion,
    required Usuario usuario,
  })  : _idRol = idRol,
        _descripcion = descripcion,
        _usuario = usuario;

  Rol.id(int idRol)
      : _idRol = idRol,
        _descripcion = "";

  Rol.json({required int idRol, required String descripcion})
      : _idRol = idRol,
        _descripcion = descripcion;

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol.json(
      idRol: json['id_rol'],
      descripcion: json['descripcion'],
    );
  }

  //Get Set
  int get idRol => _idRol;
  set idRol(int value) => _idRol = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  Usuario? get usuario => this._usuario;

  set usuario(Usuario? value) => this._usuario = value;

  //Funciones
  Map<String, dynamic> toIdJson() {
    return {
      'id_rol': _idRol,
    };
  }

  static List<Rol> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<Rol>((json) => Rol.fromJson(json))
        .toList();
  }

  //Interfaz
  @override
  bool esResidente() {
    throw UnimplementedError();
  }

  @override
  List<Familiar> getFamiliares() {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  //ToString
  @override
  String toString() {
    return toJson().toString();
  }

  String toStringMostrar() {
    return this._descripcion;
  }

  //Equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Rol && _idRol == other.idRol;
  }

  @override
  int get hashCode => _idRol.hashCode;
}
