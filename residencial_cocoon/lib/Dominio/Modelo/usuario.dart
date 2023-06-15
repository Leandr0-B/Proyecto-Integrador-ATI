import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

class Usuario {
  //Atributos
  String _ci;
  String _nombre;
  int _administrador;
  List<Rol>? _roles;
  List<Sucursal>? _sucursales;
  String? _authToken;

  //Constructores
  Usuario({
    required String ci,
    required String nombre,
    required int administrador,
    required List<Rol> roles,
    required List<Sucursal> sucursales,
    required String authToken,
  })  : _ci = ci,
        _nombre = nombre,
        _administrador = administrador,
        _roles = roles,
        _sucursales = sucursales,
        _authToken = authToken;

  Usuario.sinListas({
    required String ci,
    required String nombre,
    required int administrador,
  })  : _ci = ci,
        _nombre = nombre,
        _administrador = administrador;

  Usuario.vacio()
      : _ci = '',
        _nombre = '',
        _administrador = 0,
        _roles = [],
        _sucursales = [];

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
        authToken: json['authToken']);
  }

  //Get Set
  String get ci => _ci;
  set ci(String value) => _ci = value;

  String get nombre => _nombre;
  set nombre(String value) => _nombre = value;

  int get administrador => _administrador;
  set administrador(int value) => _administrador = value;

  set roles(List<Rol> roles) => _roles = roles;
  List<Rol>? getRoles() {
    return _roles;
  }

  set sucursales(List<Sucursal> sucursales) => _sucursales = sucursales;
  List<Sucursal>? getSucursales() {
    return _sucursales;
  }

  String? getToken() {
    return this._authToken;
  }

  //Funciones
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> rolesJson =
        _roles!.map((rol) => rol.toJson()).toList();
    List<Map<String, dynamic>> sucursalesJson =
        _sucursales!.map((sucursal) => sucursal.toJson()).toList();

    return {
      'ci': _ci,
      'nombre': _nombre,
      'administrador': _administrador,
      'roles': rolesJson,
      'sucursales': sucursalesJson,
    };
  }

  static void validarUsuario(String ci, String clave) {
    //Controla los valores de cedula y clave
    if (ci == "" || clave == "") {
      throw LoginException("Los datos de ingreso no pueden estar vacios.");
    }
  }

  //ToString
  @override
  String toString() {
    return toJson().toString();
  }
}
