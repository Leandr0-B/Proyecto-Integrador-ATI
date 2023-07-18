import 'package:flutter/rendering.dart';
import 'package:flutter/src/material/time.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/registroMedicacionConPrescripcion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
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
import 'package:residencial_cocoon/Servicios/servicioMedicacion.dart';
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
  ServicioMedicacion? _servicioMedicacion;

  //Constructor
  Fachada._() {
    _servicioUsuario = ServicioUsuario();
    _servicioSucursal = ServicioSucursal();
    _servicioSalidas = ServicioSalidas();
    _servicioCequeoMedico = ServicioCequeoMedico();
    _servicioNotificacion = ServicioNotificacion();
    _servicioControl = ServicioControl();
    _servicioMedicacion = ServicioMedicacion();
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
      String ci, String nombre, int administrador, List<int> selectedRoles, List<int> selectedSucursales, String apellido, String telefono, String email) async {
    await _servicioUsuario?.altaUsuario(ci, nombre, administrador, selectedRoles, selectedSucursales, apellido, telefono, email);
  }

  Future<void> altaUsuarioResidente(List<Familiar> familiares, String ci, String nombre, int? selectedSucursal, String apellido) async {
    await _servicioUsuario?.altaUsuarioResidente(familiares, ci, nombre, selectedSucursal, apellido);
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
  Future<void> altaSalidaMedica(Usuario? selectedResidente, String descripcion, DateTime? fechaDesde, DateTime? fechaHasta) async {
    await _servicioSalidas?.altaSalidaMedica(selectedResidente, descripcion, fechaDesde, fechaHasta);
  }

  //Chequeo
  Future<void> altaVisitaMedicaExt(Usuario? selectedResidente, String descripcion, DateTime? fecha) async {
    await _servicioCequeoMedico?.altaVisitaMedicaExt(selectedResidente, descripcion, fecha);
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

  Future<void> altaChequeoMedico(Usuario? selectedResidente, List<Control?> selectedControles, DateTime? fecha, String descripcion) async {
    await _servicioControl?.altaChequeoMedico(selectedResidente, selectedControles, fecha, descripcion);
  }

  Future<List<Notificacion>?> obtenerNotificacionesPaginadasConfiltros(int page, int limit, DateTime? desde, DateTime? hasta, String? palabras) async {
    return await _servicioNotificacion?.obtenerNotificacionesPaginadasConfiltros(page, limit, desde, hasta, palabras);
  }

  Future<int?> obtenerNotificacionesPaginadasConFiltrosCantidadTotal(DateTime? desde, DateTime? hasta, String? palabras) async {
    return await _servicioNotificacion?.obtenerNotificacionesPaginadasConFiltrosCantidadTotal(desde, hasta, palabras);
  }

  Future<List<SalidaMedica>?> obtenerSalidasMedicasPaginadasConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioSalidas?.obtenerSalidasMedicasPaginadasConfiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<int?> obtenerSalidasMedicasPaginadasConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioSalidas?.obtenerSalidasMedicasPaginadasConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<List<VisitaMedicaExterna>?> obtenerVisitasMedicasExternasPaginadasConFiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioCequeoMedico?.obtenerVisitasMedicasExternasPaginadasConFiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<int?> obtenerVisitasMedicasExternasPaginadasConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioCequeoMedico?.obtenerVisitasMedicasExternasPaginadasConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<List<ChequeoMedico>?> obtenerChequeosMedicosPaginadosConFiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioCequeoMedico?.obtenerChequeosMedicosPaginadosConFiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<int?> obtenerChequeosMedicosPaginadosConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioCequeoMedico?.obtenerChequeosMedicosPaginadosConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  void eliminarTokenNotificaciones() async {
    return await _servicioUsuario?.eliminarTokenNotificaciones();
  }

  //Medicamentos
  Future<void> altaMedicamento(String nombre, String? unidad) async {
    await _servicioMedicacion?.altaMedicamento(nombre, unidad);
  }

  Future<List<Medicamento>?> listaMedicamentos(int paginaActual, int elementosPorPagina, String cedulaResidente, String palabraClave) async {
    return await _servicioMedicacion?.listaMedicamentos(paginaActual, elementosPorPagina, cedulaResidente, palabraClave);
  }

  Future<int?> obtenerMedicamentosPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave) async {
    return await _servicioMedicacion?.obtenerMedicamentosPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave);
  }

  Future<void> asociarMedicamento(Medicamento? selectedMedicamento, Usuario? selectedResidente, int stock, int stockNotificacion) async {
    await _servicioMedicacion?.asociarMedicamento(selectedMedicamento, selectedResidente, stock, stockNotificacion);
  }

  Future<List<Medicamento>?> listaMedicamentosAsociados(int paginaActual, int elementosPorPagina, String cedulaResidente, String palabraClave) async {
    return await _servicioMedicacion?.listaMedicamentosAsociados(paginaActual, elementosPorPagina, cedulaResidente, palabraClave);
  }

  Future<int?> obtenerMedicamentosAsociadosPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave) async {
    return await _servicioMedicacion?.obtenerMedicamentosAsociadosPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave);
  }

  Future<void> registrarPrescripcion(Medicamento? selectedMedicamento, Usuario? selectedResidente, int cantidad, String descripcion, DateTime? fecha_desde, DateTime? fecha_hasta,
      int frecuencia, TimeOfDay? hora_comienzo) async {
    await _servicioMedicacion?.registrarPrescripcion(selectedMedicamento, selectedResidente, cantidad, descripcion, fecha_desde, fecha_hasta, frecuencia, hora_comienzo);
  }

  Future<List<RegistroMedicacionConPrescripcion>?> obtenerRegistrosMedicamentosConPrescripcion(DateTime? fechaFiltro, String? ciFiltro) async {
    return await _servicioMedicacion?.obtenerRegistrosMedicamentosConPrescripcion(fechaFiltro, ciFiltro);
  }

  Future<void> procesarMedicacion(RegistroMedicacionConPrescripcion? selectedRegistro) async {
    await _servicioMedicacion?.procesarMedicacion(selectedRegistro);
  }

  Future<List<RegistroMedicacionConPrescripcion>?> obtenerMedicacionesPeriodicasPaginadasConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioMedicacion?.obtenerMedicacionesPeriodicasPaginadasConfiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<int?> obtenerMedicacionesPeriodicasPaginadasConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioMedicacion?.obtenerMedicacionesPeriodicasPaginadasConFiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<List<PrescripcionDeMedicamento>?> obtenerPrescripcionesMedicamentosPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioMedicacion?.obtenerPrescripcionesMedicamentosPaginadosConfiltros(paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave);
  }

  Future<int?> obtenerPrescripcionesMedicamentosPaginadosConfiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    return await _servicioMedicacion?.obtenerPrescripcionesMedicamentosPaginadosConfiltrosCantidadTotal(fechaDesde, fechaHasta, ciResidente, palabraClave);
  }
}
