import 'package:flutter/rendering.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/chequeoMedico.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/salidaMedica.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Dominio/Modelo/visitaMedicaExterna.dart';
import 'package:residencial_cocoon/Servicios/servicioChequeoMedico.dart';
import 'package:residencial_cocoon/Servicios/servicioNotificacion.dart';
import 'package:residencial_cocoon/Servicios/servicioControl.dart';
import 'package:residencial_cocoon/Servicios/servicioSalidas.dart';
import 'package:residencial_cocoon/Servicios/servicioSucursal.dart';
import 'package:residencial_cocoon/Servicios/servicioUsuario.dart';

class Fachada {
  //Atributos
  Usuario? _usuario;
  static Fachada? _instancia;
  ServicioUsuario? _servicioUsuario;
  ServicioSucursal? _servicioSucursal;
  ServicioSalidas? _servicioSalidas;
  ServicioCequeoMedico? _servicioCequeoMedico;
  ServicioNotificacion? _servicioNotificacion;
  ServicioControl? _servicioControl;

  //Constructor
  Fachada._() {
    _servicioUsuario = ServicioUsuario();
    _servicioSucursal = ServicioSucursal();
    _servicioSalidas = ServicioSalidas();
    _servicioCequeoMedico = ServicioCequeoMedico();
    _servicioNotificacion = ServicioNotificacion();
    _servicioControl = ServicioControl();
  }

  static Fachada? getInstancia() {
    _instancia ??= Fachada._();
    return _instancia;
  }

  //Funciones
  //Usuario
  Future<Usuario?> login(String ci, String clave) async {
    return await _servicioUsuario?.login(ci, clave);
  }

  Usuario? getUsuario() {
    return this._usuario;
  }

  void setUsuario(Usuario? usuario) {
    this._usuario = usuario;
  }

  Future<List<Rol>?> listaRoles() async {
    return await _servicioUsuario?.listaRoles();
  }

  Future<void> altaUsuario(
      String ci,
      String nombre,
      int administrador,
      List<int> selectedRoles,
      List<int> selectedSucursales,
      String apellido,
      String telefono,
      String email) async {
    await _servicioUsuario?.altaUsuario(ci, nombre, administrador,
        selectedRoles, selectedSucursales, apellido, telefono, email);
  }

  Future<void> altaUsuarioResidente(List<Familiar> familiares, String ci,
      String nombre, int? selectedSucursal, String apellido) async {
    await _servicioUsuario?.altaUsuarioResidente(
        familiares, ci, nombre, selectedSucursal, apellido);
  }

  Future<List<Usuario>?> obtenerUsuarios() async {
    return await _servicioUsuario?.obtenerUsuarios();
  }

  Future<Usuario?> obtenerUsuarioToken(String token) async {
    return await _servicioUsuario?.obtenerUsuarioToken(token);
  }

  Future<void> cambioClave(String actual, String nueva) async {
    await _servicioUsuario?.cambioClave(actual, nueva);
  }

  Future<List<Usuario>?> residentesSucursal(Sucursal? suc) async {
    return await _servicioUsuario?.residentesSucursal(suc);
  }

  Future<void> actualizarTokenNotificaciones(String notificationToken) async {
    await _servicioUsuario?.actualizarTokenNotificaciones(notificationToken);
  }

  //Sucursal
  Future<List<Sucursal>?> listaSucursales() async {
    return await _servicioSucursal?.listaSucursales();
  }

  //Salida
  Future<void> altaSalidaMedica(Usuario? selectedResidente, String descripcion,
      DateTime? fechaDesde, DateTime? fechaHasta) async {
    await _servicioSalidas?.altaSalidaMedica(
        selectedResidente, descripcion, fechaDesde, fechaHasta);
  }

  //Chequeo
  Future<void> altaVisitaMedicaExt(
      Usuario? selectedResidente, String descripcion, DateTime? fecha) async {
    await _servicioCequeoMedico?.altaVisitaMedicaExt(
        selectedResidente, descripcion, fecha);
  }

  Future<int?> cantidadNotifiacionesSinLeer() async {
    return await _servicioNotificacion?.cantidadNotifiacionesSinLeer();
  }

  void marcarNotificacionComoLeida(Notificacion notificacion) async {
    _servicioNotificacion?.marcarNotificacionComoLeida(notificacion);
  }

  //Control
  Future<List<Control>?> listaControles() async {
    return await _servicioControl?.listaControles();
  }

  Future<void> altaChequeoMedico(
      Usuario? selectedResidente,
      List<Control?> selectedControles,
      DateTime? fecha,
      String descripcion) async {
    await _servicioControl?.altaChequeoMedico(
        selectedResidente, selectedControles, fecha, descripcion);
  }

  Future<List<Notificacion>?> obtenerNotificacionesPaginadasConfiltros(int page,
      int limit, DateTime? desde, DateTime? hasta, String? palabras) async {
    return await _servicioNotificacion
        ?.obtenerNotificacionesPaginadasConfiltros(
            page, limit, desde, hasta, palabras);
  }

  Future<int?> obtenerNotificacionesPaginadasConFiltrosCantidadTotal(
      DateTime? desde, DateTime? hasta, String? palabras) async {
    return await _servicioNotificacion
        ?.obtenerNotificacionesPaginadasConFiltrosCantidadTotal(
            desde, hasta, palabras);
  }

  Future<List<SalidaMedica>?> obtenerSalidasMedicasPaginadasConfiltros(
      int paginaActual,
      int elementosPorPagina,
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      String? ciResidente,
      String? palabraClave) async {
    return await _servicioSalidas?.obtenerSalidasMedicasPaginadasConfiltros(
        paginaActual,
        elementosPorPagina,
        fechaDesde,
        fechaHasta,
        ciResidente,
        palabraClave);
  }

  Future<int?> obtenerSalidasMedicasPaginadasConFiltrosCantidadTotal(
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      String? ciResidente,
      String? palabraClave) async {
    return await _servicioSalidas
        ?.obtenerSalidasMedicasPaginadasConFiltrosCantidadTotal(
            fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<List<VisitaMedicaExterna>?>
      obtenerVisitasMedicasExternasPaginadasConFiltros(
          int paginaActual,
          int elementosPorPagina,
          DateTime? fechaDesde,
          DateTime? fechaHasta,
          String? ciResidente,
          String? palabraClave) async {
    return await _servicioCequeoMedico
        ?.obtenerVisitasMedicasExternasPaginadasConFiltros(
            paginaActual,
            elementosPorPagina,
            fechaDesde,
            fechaHasta,
            ciResidente,
            palabraClave);
  }

  Future<int?> obtenerVisitasMedicasExternasPaginadasConFiltrosCantidadTotal(
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      String? ciResidente,
      String? palabraClave) async {
    return await _servicioCequeoMedico
        ?.obtenerVisitasMedicasExternasPaginadasConFiltrosCantidadTotal(
            fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<List<ChequeoMedico>?> obtenerChequeosMedicosPaginadosConFiltros(
      int paginaActual,
      int elementosPorPagina,
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      String? ciResidente,
      String? palabraClave) async {
    return await _servicioCequeoMedico
        ?.obtenerChequeosMedicosPaginadosConFiltros(
            paginaActual,
            elementosPorPagina,
            fechaDesde,
            fechaHasta,
            ciResidente,
            palabraClave);
  }

  Future<int?> obtenerChequeosMedicosPaginadosConFiltrosCantidadTotal(
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      String? ciResidente,
      String? palabraClave) async {
    return await _servicioCequeoMedico
        ?.obtenerChequeosMedicosPaginadosConFiltrosCantidadTotal(
            fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  void eliminarTokenNotificaciones() async {
    return await _servicioUsuario?.eliminarTokenNotificaciones();
  }
}
