import 'package:residencial_cocoon/Modelo/rol.dart';
import 'package:residencial_cocoon/Modelo/sucurusal.dart';

class Usuario {
  String _ci;
  String _nombre;
  int _administrador;
  List<Rol> _roles;
  List<Sucursal> _sucursales;

  Usuario({
    required String ci,
    required String nombre,
    required int administrador,
    required List<Rol> roles,
    required List<Sucursal> sucursales,
  })  : _ci = ci,
        _nombre = nombre,
        _administrador = administrador,
        _roles = roles,
        _sucursales = sucursales;

  String get ci => _ci;
  set ci(String value) => _ci = value;

  String get nombre => _nombre;
  set nombre(String value) => _nombre = value;

  int get administrador => _administrador;
  set administrador(int value) => _administrador = value;

  List<Rol> get roles => _roles;
  set roles(List<Rol> value) => _roles = value;

  List<Sucursal> get sucursales => _sucursales;
  set sucursales(List<Sucursal> value) => _sucursales = value;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    List<Rol> rolesList = [];
    List<Sucursal> sucursalesList = [];

    // Recuperar los roles del JSON y convertirlos en objetos de Rol
    List<dynamic> rolesJson = json['roles'];
    rolesList = rolesJson.map((roleJson) => Rol.fromJson(roleJson)).toList();

    // Recuperar las sucursales del JSON y convertirlas en objetos de Sucursal
    List<dynamic> sucursalesJson = json['sucursales'];
    sucursalesList = sucursalesJson
        .map((sucursalJson) => Sucursal.fromJson(sucursalJson))
        .toList();

    // Crear y retornar un nuevo objeto Usuario
    return Usuario(
      ci: json['ci'],
      nombre: json['nombre'],
      administrador: json['administrador'],
      roles: rolesList,
      sucursales: sucursalesList,
    );
  }

  @override
  String toString() {
    return 'Usuario(ci: $_ci, nombre: $_nombre, administrador: $_administrador, roles: $_roles, sucursales: $_sucursales)';
  }
}
