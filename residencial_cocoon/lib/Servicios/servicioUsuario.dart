import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
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

    Usuario usu = Usuario.login(jsonMap);

    print(usu.toString());

    return usu;
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
    Usuario usu = Usuario.login(jsonMap);
    return usu;
  }

  Future<void> cambioClave(String actual, String nueva) async {
    await APIService.fetchUserPass(
        actual, nueva, Fachada.getInstancia()?.getUsuario()?.getToken());
  }
}
