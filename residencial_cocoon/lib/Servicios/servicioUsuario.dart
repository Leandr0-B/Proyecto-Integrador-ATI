import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
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
    String roles = await APIService.fetchRoles(Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList = jsonDecode(roles); // convert the JSON text to a List
    return Rol.fromJsonList(jsonList);
  }

  Future<void> altaUsuario(String ci, String nombre, int administrador, List<int> selectedRoles, List<int> selectedSucursales, String apellido, String telefono, String email,
      DateTime? fechaNacimiento) async {
    DateTime fecha_nacimiento_sin_hora = DateTime(fechaNacimiento!.year, fechaNacimiento!.month, fechaNacimiento!.day);
    String fecha_nacimiento_formateada = DateFormat('yyyy-MM-dd').format(fecha_nacimiento_sin_hora);
    if (administrador == 0) {
      Usuario.validarRoles(selectedRoles);
      Usuario.validarSucursales(selectedSucursales);
    }
    await APIService.postAltaUsuario(
        ci, nombre, administrador, selectedRoles, selectedSucursales, Fachada.getInstancia()?.getUsuario()?.getToken(), apellido, telefono, email, fecha_nacimiento_formateada);
  }

  Future<void> altaUsuarioResidente(List<Familiar> familiares, String ci, String nombre, int? selectedSucursal, String apellido, DateTime? fechaNacimiento) async {
    List<Map<String, dynamic>> familiaresJsonList = familiares.map((familiar) => familiar.toJson()).toList();
    List<int?> sucursales = [];
    sucursales.add(selectedSucursal);
    DateTime fecha_nacimiento_sin_hora = DateTime(fechaNacimiento!.year, fechaNacimiento!.month, fechaNacimiento!.day);
    String fecha_nacimiento_formateada = DateFormat('yyyy-MM-dd').format(fecha_nacimiento_sin_hora);
    await APIService.postAltaUsuarioResidente(ci, nombre, familiaresJsonList, sucursales, Fachada.getInstancia()?.getUsuario()?.getToken(), apellido, fecha_nacimiento_formateada);
  }

  Future<List<Usuario>?> obtenerUsuarios() async {
    String usuarios = await APIService.fetchUsuarios(Fachada.getInstancia()?.getUsuario()!.getToken());

    List<dynamic> jsonList = jsonDecode(usuarios);
    return Usuario.listadoJson(jsonList);
  }

  Future<Usuario>? obtenerUsuarioToken(String token) async {
    String respuesta = await APIService.fetchUserInfo(token);
    Map<String, dynamic> jsonMap = jsonDecode(respuesta);
    Usuario usu = Usuario.login(jsonMap);
    return usu;
  }

  Future<void> cambioClave(String actual, String nueva) async {
    await APIService.putUserPass(actual, nueva, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<Usuario>?> residentesSucursal(Sucursal? suc) async {
    String usuarios = await APIService.fetchUsuariosSucursal(Fachada.getInstancia()?.getUsuario()?.getToken(), suc?.idSucursal);
    List<dynamic> jsonList = jsonDecode(usuarios);
    return Usuario.listadoJsonResidentes(jsonList);
  }

  Future<void> actualizarTokenNotificaciones(String notificationToken) async {
    await APIService.actualizarTokenNotificaciones(notificationToken, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<void> eliminarTokenNotificaciones() async {
    await APIService.eliminarTokenNotificaciones(Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<Usuario>?> obtenerUsuariosPaginadasConfiltros(
      int paginaActual, int elementosPorPagina, String? ciResidente, String? palabraClaveNombre, String? palabraClaveApellido) async {
    String usuarios = await APIService.obtenerUsuariosPaginadasConFiltros(
        paginaActual, elementosPorPagina, ciResidente, palabraClaveNombre, palabraClaveApellido, Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList = jsonDecode(usuarios);
    return Usuario.listadoJson(jsonList);
  }

  Future<int?> obtenerUsuariosPaginadasConFiltrosCantidadTotal(String? ciResidente, String? palabraClaveNombre, String? palabraClaveApellido) async {
    String cantidadTotal =
        await APIService.obtenerUsuariosPaginadasConFiltrosCantidadTotal(ciResidente, palabraClaveNombre, palabraClaveApellido, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<List<Familiar>?> obtenerFamiliaresPaginadosConfiltros(int paginaActual, int elementosPorPagina, String? ciResidente, String? ciFamiliar) async {
    String familiares =
        await APIService.obtenerFamiliaresPaginadosConfiltros(paginaActual, elementosPorPagina, ciResidente, ciFamiliar, Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList = jsonDecode(familiares);
    return Familiar.listaVistaPrevia(jsonList);
  }

  Future<int?> obtenerFamiliaresPaginadosConfiltrosCantidadTotal(String? ciResidente, String? ciFamiliar) async {
    String cantidadTotal = await APIService.obtenerFamiliaresPaginadosConfiltrosCantidadTotal(ciResidente, ciFamiliar, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<void> altaFamiliar(
      String? ciResidente, String ciFamiliarAlta, String nombreFamiliarAlta, String apellidoFamiliarAlta, String emailFamiliarAlta, String telefonoFamiliarAlta) async {
    await APIService.altaFamiliar(
        ciResidente, ciFamiliarAlta, nombreFamiliarAlta, apellidoFamiliarAlta, emailFamiliarAlta, telefonoFamiliarAlta, Fachada.getInstancia()?.getUsuario()!.getToken());
  }
}
