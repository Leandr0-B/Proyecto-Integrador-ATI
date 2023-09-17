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
  String _apellido = "";
  String _telefono = "";
  String _email = "";
  DateTime _fechaNacimiento = DateTime(0);
  int _administrador = 0;
  List<Rol> _roles = [];
  List<Sucursal> _sucursales = [];
  String _authToken = "";
  int _inactivo = 0;
  String _tokenNotificacion = "";

  // Constructores
  Usuario.empty();

  Usuario(this._ci, this._nombre, this._administrador, this._roles, this._sucursales, this._authToken, this._tokenNotificacion, this._apellido, this._telefono, this._email);

  Usuario.paraLista(
    this._ci,
    this._nombre,
    this._administrador,
    this._roles,
    this._sucursales,
    this._inactivo,
    this._apellido,
    this._telefono,
    this._email,
    this._fechaNacimiento,
  );

  Usuario.residente(
    this._ci,
    this._nombre,
    this._roles,
    this._apellido,
  );

  Usuario.sinRoles(this._ci, this._nombre, this._administrador, this._sucursales, this._authToken, this._tokenNotificacion);

  // Constructor utilizado para logearte
  factory Usuario.login(Map<String, dynamic> json) {
    List<Rol> rolesList = [];
    List<Sucursal> sucursalesList = [];

    // Recuperar las sucursales del JSON y convertirlas en objetos de Sucursal
    List<dynamic> sucursalesJson = json['sucursales'];
    sucursalesList = sucursalesJson.map((sucursalJson) => Sucursal.fromJson(sucursalJson)).toList();

    // Recuperar los roles del Json y convertirlos en objetos de Rol
    List<dynamic> roles = json['roles'];
    rolesList = roles.map((rol) => Rol.fromJsonToEspecializacion(rol)).toList();

    Usuario aux = Usuario(json['ci'], json['nombre'], json['administrador'], rolesList, sucursalesList, json['authToken'], json['tokenNotificacion'] ?? "", json['apellido'],
        json['telefono'], json['email']);

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
    rolesList = rolesJson.map((roleJson) => Rol.fromJsonToEspecializacion(roleJson)).toList();

    //recuperar los familiares del JSON y meterlos en el Rol Residente
    if (json.containsKey('familiares')) {
      List<dynamic> familiaresJson = json['familiares'];
      familiaresList = familiaresJson.map((familiarJson) => Familiar.fromJson(familiarJson)).toList();

      for (int i = 0; i < rolesList.length; i++) {
        if (rolesList[i].esResidente()) {
          (rolesList[i] as Residente).familiares = familiaresList;
        }
      }
    }

    // Recuperar las sucursales del JSON y convertirlas en objetos de Sucursal
    List<dynamic> sucursalesJson = json['sucursales'];
    sucursalesList = sucursalesJson.map((sucursalJson) => Sucursal.fromJson(sucursalJson)).toList();

    // Crear y retornar un nuevo objeto Usuario
    return Usuario.paraLista(
      json['ci'],
      json['nombre'],
      json['administrador'] ?? 0,
      rolesList,
      sucursalesList,
      json['inactivo'] ?? 0,
      json['apellido'],
      json['telefono'],
      json['email'],
      DateTime.parse(json['fecha_nacimiento']),
    );
  }

  factory Usuario.fromJsonListaResidente(Map<String, dynamic> json) {
    List<Rol> rolesList = [];
    rolesList.add(Residente.sinFamiliares(3, "Residente"));

    Usuario aux = Usuario.residente(
      json['ci'],
      json['nombre'],
      rolesList,
      json['apellido'],
    );

    for (int i = 0; i < rolesList.length; i++) {
      rolesList[i].usuario = aux;
    }
    return aux;
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

  void setToken(String token) {
    _authToken = token;
  }

  String get apellido => this._apellido;

  set apellido(String value) => this._apellido = value;

  String get telefono => this._telefono;

  set telefono(String value) => this._telefono = value;

  String get email => this._email;

  set email(String value) => this._email = value;

  //Funciones
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
      throw Exception("Seleccione al menos un rol.");
    }
  }

  static void validarSucursales(List<int> sucursales) {
    if (sucursales.isEmpty) {
      throw Exception("Seleccione al menos una sucursal.");
    }
  }

  static List<Usuario> listadoJson(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<Usuario>((json) => Usuario.fromJsonLista(json)).toList();
  }

  static List<Usuario> listadoJsonResidentes(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<Usuario>((json) => Usuario.fromJsonListaResidente(json)).toList();
  }

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

  bool esAdministrador() {
    return administrador == 1;
  }

  void agregarRol(Rol rol) {
    rol.usuario = this;
    _roles.add(rol);
  }

  static bool esEmailValido(String email) {
    // Expresión regular para verificar el formato del email
    const pattern = r'^[a-zA-Z0-9-ñÑ_.]+@[a-zA-Z0-9-ñÑ]+(\.[a-zA-Z0-9-ñÑ]+)*(\.[a-zA-ZñÑ]{2,})$';
    final regex = RegExp(pattern, caseSensitive: false);

    return regex.hasMatch(email);
  }

  String telefonoFamiliar() {
    String telefono = '';
    for (var rol in _roles) {
      if (rol.esResidente()) {
        telefono = rol.obtenerTelefono();
      }
    }
    return telefono;
  }

  int mostrarEdad() {
    final DateTime ahora = DateTime.now();
    int edad = ahora.year - this._fechaNacimiento.year;

    // Ajusta la edad si aún no ha tenido su cumpleaños este año
    if (ahora.month < this._fechaNacimiento.month || (ahora.month == this._fechaNacimiento.month && ahora.day < this._fechaNacimiento.day)) {
      edad--;
    }

    return edad;
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "ci: $_ci, ";
    retorno += "nombre: $_nombre, ";
    retorno += "apellido: $_apellido, ";
    retorno += "administrador: $_administrador, ";
    retorno += "roles: $roles, ";
    retorno += "sucursales: $sucursales, ";
    retorno += "authToken: $_authToken, ";
    retorno += "tokenNotificacion: $_tokenNotificacion";
    return retorno;
  }
}
