import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

class Usuario {
  //Atributos
  String _ci = "";
  String _nombre = "";
  int _administrador = 0;
  List<Rol> _roles = [];
  List<Sucursal> _sucursales = [];
  String _authToken = "";
  int _inactivo = 0;
  String _tokenNotificacion = "";

  // Constructores
  Usuario.empty();

  Usuario(this._ci, this._nombre, this._administrador, this._roles,
      this._sucursales, this._authToken, this._tokenNotificacion);

  Usuario.paraLista(
    this._ci,
    this._nombre,
    this._administrador,
    this._roles,
    this._sucursales,
    this._inactivo,
  );

  Usuario.sinRoles(this._ci, this._nombre, this._administrador,
      this._sucursales, this._authToken, this._tokenNotificacion);

  // Constructor utilizado para logearte
  factory Usuario.login(Map<String, dynamic> json) {
    List<Rol> rolesList = [];
    List<Sucursal> sucursalesList = [];

    // Recuperar las sucursales del JSON y convertirlas en objetos de Sucursal
    List<dynamic> sucursalesJson = json['sucursales'];
    sucursalesList = sucursalesJson
        .map((sucursalJson) => Sucursal.fromJson(sucursalJson))
        .toList();

    // Recuperar los roles del Json y convertirlos en objetos de Rol
    List<dynamic> roles = json['roles'];
    rolesList = roles.map((rol) => Rol.fromJsonToEspecializacion(rol)).toList();

    Usuario aux = Usuario(
        json['ci'],
        json['nombre'],
        json['administrador'],
        rolesList,
        sucursalesList,
        json['authToken'],
        json['tokenNotificacion'] ?? "");

    for (int i = 0; i < rolesList.length; i++) {
      rolesList[i].usuario = aux;
    }
    return aux;
  }

  factory Usuario.fromJsonLista(Map<String, dynamic> json) {
    List<Rol> rolesList = [];
    List<Sucursal> sucursalesList = [];
    List<Familiar> familiaresList = [];

    // Recuperar los roles del JSON y convertirlos en objetos de Rol
    List<dynamic> rolesJson = json['roles'];
    rolesList = rolesJson
        .map((roleJson) => Rol.fromJsonToEspecializacion(roleJson))
        .toList();

    //recuperar los familiares del JSON y meterlos en el Rol Residente
    if (json.containsKey('familiares')) {
      List<dynamic> familiaresJson = json['familiares'];
      familiaresList = familiaresJson
          .map((familiarJson) => Familiar.fromJson(familiarJson))
          .toList();

      for (int i = 0; i < rolesList.length; i++) {
        if (rolesList[i].esResidente()) {
          (rolesList[i] as Residente).familiares = familiaresList;
        }
      }
    }

    // Recuperar las sucursales del JSON y convertirlas en objetos de Sucursal
    List<dynamic> sucursalesJson = json['sucursales'];
    sucursalesList = sucursalesJson
        .map((sucursalJson) => Sucursal.fromJson(sucursalJson))
        .toList();

    // Crear y retornar un nuevo objeto Usuario
    return Usuario.paraLista(
        json['ci'],
        json['nombre'],
        json['administrador'] ?? 0,
        rolesList,
        sucursalesList,
        json['inactivo'] ?? 0);
  }

  //Get Set
  String get ci => _ci;

  set ci(String value) => _ci = value;

  String get nombre => _nombre;
  set nombre(String value) => _nombre = value;

  int get administrador => _administrador;
  set administrador(int value) => _administrador = value;

  set roles(List<Rol> roles) => _roles = roles;
  List<Rol> get roles => this._roles;

  String get tokenNotificacion => this._tokenNotificacion;

  set tokenNotificacion(String value) => this._tokenNotificacion = value;

  List<Sucursal> get sucursales => this._sucursales;
  set sucursales(List<Sucursal> sucursales) => _sucursales = sucursales;
  List<Sucursal>? getSucursales() {
    return _sucursales;
  }

  String? getToken() {
    return _authToken;
  }

  List<Familiar>? getfamiliares() {
    List<Familiar>? lista = [];
    for (Rol element in _roles) {
      if (element.esResidente()) {
        lista = (element as Residente).getFamiliares();
      }
    }
    return lista;
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

  // static String listaFamiliaresToJson(List<Familiar> familiares) {
  //   List<Map<String, dynamic>> jsonList =
  //       familiares.map((familiar) => familiar.toJson()).toList();
  //   String jsonString = jsonEncode(jsonList);
  //   return jsonString.replaceAll('\\', '');
  // }

  bool esResidente() {
    bool resultado = false;
    for (Rol element in _roles) {
      resultado = element.esResidente();
    }
    return resultado;
  }

  bool esNutricionista() {
    bool resultado = false;
    for (Rol element in _roles) {
      resultado = element.esNutricionista();
    }
    return resultado;
  }

  bool esEnfermero() {
    bool resultado = false;
    for (Rol element in _roles) {
      resultado = element.esEnfermero();
    }
    return resultado;
  }

  bool esCocinero() {
    bool resultado = false;
    for (Rol element in _roles) {
      resultado = element.esCocinero();
    }
    return resultado;
  }

  bool esGeriatra() {
    bool resultado = false;
    for (Rol element in _roles) {
      resultado = element.esGeriatra();
    }
    return resultado;
  }

  void agregarRol(Rol rol) {
    rol.usuario = this;
    _roles.add(rol);
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "ci: $_ci, ";
    retorno += "nombre: $_nombre, ";
    retorno += "administrador: $_administrador, ";
    retorno += "roles: $roles, ";
    retorno += "sucursales: $sucursales, ";
    retorno += "authToken: $_authToken, ";
    retorno += "tokenNotificacion: $_tokenNotificacion";
    return retorno;
  }
}
