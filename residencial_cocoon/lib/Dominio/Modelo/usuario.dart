import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/cocinero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/enfermero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/nutricionista.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'dart:convert';

class Usuario {
  //Atributos
  String? _ci;
  String? _nombre;
  int? _administrador;
  List<Rol>? _roles;
  List<Sucursal>? _sucursales;
  String? _authToken;
  int? _inactivo;
  String? _tokenNotificacion;

  //Constructores
  Usuario.rolTest(this._roles);

  Usuario({
    required String ci,
    required String nombre,
    required int administrador,
    required List<Rol> roles,
    required List<Sucursal> sucursales,
    required String authToken,
    required String tokenNotificacion,
  })  : _ci = ci,
        _nombre = nombre,
        _administrador = administrador,
        _roles = roles,
        _sucursales = sucursales,
        _authToken = authToken,
        _tokenNotificacion = tokenNotificacion;

  Usuario.paraLista({
    required String ci,
    required String nombre,
    required int administrador,
    required List<Rol> roles,
    required List<Sucursal> sucursales,
    required int inactivo,
  })  : _ci = ci,
        _nombre = nombre,
        _administrador = administrador,
        _roles = roles,
        _sucursales = sucursales,
        _inactivo = inactivo;

  Usuario.sinRoles({
    required String? ci,
    required String? nombre,
    required int? administrador,
    required List<Sucursal>? sucursales,
    required String? authToken,
    required String? tokenNotificacion,
  })  : _ci = ci,
        _nombre = nombre,
        _administrador = administrador,
        _sucursales = sucursales,
        _authToken = authToken,
        _tokenNotificacion = tokenNotificacion,
        _roles = [];

  factory Usuario.fromJson(Map<String, dynamic> json) {
    List<Rol> rolesList = [];
    List<Sucursal> sucursalesList = [];

    // Recuperar las sucursales del JSON y convertirlas en objetos de Sucursal
    List<dynamic> sucursalesJson = json['sucursales'];
    sucursalesList = sucursalesJson
        .map((sucursalJson) => Sucursal.fromJson(sucursalJson))
        .toList();

    return Usuario(
        ci: json['ci'],
        nombre: json['nombre'],
        administrador: json['administrador'],
        roles: rolesList,
        sucursales: sucursalesList,
        authToken: json['authToken'] ?? '',
        tokenNotificacion: json['tokenNotificacion']);
  }

  factory Usuario.fromJsonLista(Map<String, dynamic> json) {
    List<Rol> rolesList = [];
    List<Sucursal> sucursalesList = [];
    List<Familiar> familiaresList = [];

    // Recuperar los roles del JSON y convertirlos en objetos de Rol
    List<dynamic> rolesJson = json['roles'];
    rolesList = rolesJson.map((roleJson) => Rol.fromJson(roleJson)).toList();

    // Recuperar las sucursales del JSON y convertirlas en objetos de Sucursal
    List<dynamic> sucursalesJson = json['sucursales'];
    sucursalesList = sucursalesJson
        .map((sucursalJson) => Sucursal.fromJson(sucursalJson))
        .toList();

    if (json.containsKey('familiares')) {
      List<dynamic> familiaresJson = json['familiares'];
      familiaresList = familiaresJson
          .map((familiarJson) => Familiar.fromJson(familiarJson))
          .toList();
    }

    // Crear y retornar un nuevo objeto Usuario
    return Usuario.paraLista(
        ci: json['ci'],
        nombre: json['nombre'],
        administrador: json['administrador'] ?? 0,
        roles: rolesList,
        sucursales: sucursalesList,
        inactivo: json['inactivo'] ?? 0);
  }

  //Get Set
  String? get ci => _ci;

  set ci(String? value) => _ci = value;

  String? get nombre => _nombre;
  set nombre(String? value) => _nombre = value;

  int? get administrador => _administrador;
  set administrador(int? value) => _administrador = value;

  set roles(List<Rol>? roles) => _roles = roles;
  List<Rol>? get roles => this._roles;

  String? get tokenNotificacion => this._tokenNotificacion;

  set tokenNotificacion(String? value) => this._tokenNotificacion = value;

  List<Sucursal>? get sucursales => this._sucursales;
  set sucursales(List<Sucursal>? sucursales) => _sucursales = sucursales;
  List<Sucursal>? getSucursales() {
    return _sucursales;
  }

  String? getToken() {
    return this._authToken;
  }

  List<Familiar>? getfamiliares() {
    List<Familiar>? lista = [];
    _roles?.forEach((element) {
      if (element.esResidente()) {
        lista = element.getFamiliares();
      }
    });
    return lista;
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
      'authToken': _authToken,
      'tokenNotificacion': _tokenNotificacion
    };
  }

  static void validarUsuario(String ci, String clave) {
    //Controla los valores de cedula y clave
    if (ci == "" || clave == "") {
      throw LoginException("Los datos de ingreso no pueden estar vacios.");
    }
  }

  static void validarRoles(List<int> roles) {
    if (roles.isEmpty) {
      throw AltaUsuarioException("Seleccione al menos un rol.");
    }
  }

  static void validarSucursales(List<int> sucursales) {
    if (sucursales.isEmpty) {
      throw AltaUsuarioException("Seleccione al menos una sucursal.");
    }
  }

  static List<Usuario> listadoJson(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<Usuario>((json) => Usuario.fromJsonLista(json))
        .toList();
  }

  static String listaFamiliaresToJson(List<Familiar> familiares) {
    List<Map<String, dynamic>> jsonList =
        familiares.map((familiar) => familiar.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    return jsonString.replaceAll('\\', '');
  }

  bool contieneRol(String rol) {
    bool resultado = false;
    _roles?.forEach((element) {
      if (element.descripcion == rol) {
        resultado = true;
      }
    });
    return resultado;
  }

  bool esResidente() {
    bool resultado = false;
    _roles?.forEach((element) {
      resultado = element.esResidente();
    });
    return resultado;
  }

  void agregarRol(Rol rol) {
    rol.usuario = this;
    _roles?.add(rol);
  }

  //ToString
  @override
  String toString() {
    return toJson().toString();
  }
}
