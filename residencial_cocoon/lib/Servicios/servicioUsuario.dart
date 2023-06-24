import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/cocinero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/enfermero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/nutricionista.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'dart:convert';

import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioUsuario {
  //Atributos

  //Constructor
  ServicioUsuario();

  //Funciones
  Future<Usuario?> login(String ci, String clave) async {
    // validar la CI y la Clave
    Usuario.validarUsuario(ci, clave);
    ci = _limpieza(ci);
    String usuario = await APIService.fetchAuth(ci, clave);
    Map<String, dynamic> jsonMap = jsonDecode(usuario);
    Usuario usu = Usuario.fromJson(jsonMap);

    print(usu);

    List<dynamic> rolesJson = jsonMap['roles'];

    Usuario usu2 = Usuario.sinRoles(
        ci: usu.ci,
        nombre: usu.nombre,
        administrador: usu.administrador,
        sucursales: usu.sucursales,
        authToken: usu.getToken(),
        tokenNotificacion: usu.tokenNotificacion);

    List<Rol> roles = armarRoles(usu, rolesJson);
    //usu.roles = roles;
    print(usu);
    return usu;
  }

  List<Rol> armarRoles(Usuario u, List<dynamic> roles) {
    List<Rol> rolesList = [];
    for (var roleJson in roles) {
      switch (roleJson['id_rol']) {
        case 1:
          rolesList.add(Cocinero(
            idRol: roleJson['id_rol'],
            descripcion: roleJson['descripcion'],
            usuario: u,
          ));
          break;
        case 2:
          rolesList.add(Nutricionista(
            idRol: roleJson['id_rol'],
            descripcion: roleJson['descripcion'],
            usuario: u,
          ));
          break;
        case 3:
          //List<Familiar> familiaresList = [];
          /*
          if (json.containsKey('familiares')) {
            List<dynamic> familiaresJson = json['familiares'];
            familiaresList = familiaresJson
                .map((familiarJson) => Familiar.fromJson(familiarJson))
                .toList();
          }
          */
          Rol res = Residente(
            idRol: roleJson['id_rol'],
            descripcion: roleJson['descripcion'],
            usuario: u,
          );
          u.roles?.add(res);
          rolesList.add(res);
          break;
        case 4:
          rolesList.add(Geriatra(
            idRol: roleJson['id_rol'],
            descripcion: roleJson['descripcion'],
            usuario: u,
          ));
          break;
        case 5:
          Enfermero enf = Enfermero(
            idRol: roleJson['id_rol'],
            descripcion: roleJson['descripcion'],
            usuario: u,
          );
          rolesList.add(enf);
          break;
        default:
          break;
      }
    }
    return rolesList;
  }

  String _limpieza(String ci) {
    //Limpia los puntos y guiones de la cedula
    if (ci.contains(".")) {
      ci = ci.replaceAll(".", "");
    }
    if (ci.contains("-")) {
      ci = ci.replaceAll("-", "");
    }
    return ci;
  }

  Future<List<Rol>?> listaRoles() async {
    String roles = await APIService.fetchRoles(
        Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList =
        jsonDecode(roles); // convert the JSON text to a List
    return Rol.fromJsonList(jsonList);
  }

  Future<void> altaUsuario(String ci, String nombre, int administrador,
      List<int> selectedRoles, List<int> selectedSucursales) async {
    Usuario.validarRoles(selectedRoles);
    Usuario.validarSucursales(selectedSucursales);
    await APIService.fetchAltaUsuario(ci, nombre, administrador, selectedRoles,
        selectedSucursales, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<void> altaUsuarioResidente(List<Familiar> familiares, String ci,
      String nombre, int? selectedSucursal) async {
    List<Map<String, dynamic>> familiaresJsonList =
        familiares.map((familiar) => familiar.toJson()).toList();
    List<int?> sucursales = [];
    sucursales.add(selectedSucursal);
    await APIService.fetchAltaUsuarioResidente(ci, nombre, familiaresJsonList,
        sucursales, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<Usuario>?> obtenerUsuarios() async {
    String usuarios = await APIService.fetchUsuarios(
        Fachada.getInstancia()?.getUsuario()!.getToken());

    List<dynamic> jsonList = jsonDecode(usuarios);
    return await Usuario.listadoJson(jsonList);
  }

  Future<Usuario>? obtenerUsuarioToken(String token) async {
    String respuesta = await APIService.fetchUserInfo(token);
    Map<String, dynamic> jsonMap = jsonDecode(respuesta);
    Usuario usu = Usuario.fromJson(jsonMap);
    return usu;
  }

  Future<void> cambioClave(String actual, String nueva) async {
    await APIService.fetchUserPass(
        actual, nueva, Fachada.getInstancia()?.getUsuario()?.getToken());
  }
}
