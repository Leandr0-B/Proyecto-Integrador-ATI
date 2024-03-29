import 'dart:convert';

import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/registroMedicacionConPrescripcion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioMedicacion {
  //Atributos

  //Constructor
  ServicioMedicacion();

  //Funciones
  Future<void> altaMedicamento(String nombre, String? unidad) async {
    await APIService.postMedicamento(nombre, unidad, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<Medicamento>?> obtenerMedicamentosPaginadosConFiltros(int paginaActual, int elementosPorPagina, String? palabraClave) async {
    String medicamentos = await APIService.obtenerMedicamentosPaginadosConFiltros(paginaActual, elementosPorPagina, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(medicamentos);
    return Medicamento.fromJsonList(jsonList);
  }

  Future<int?> obtenerMedicamentosPaginadosConFiltrosCantidadTotal(String? palabraClave) async {
    String cantidadTotal = await APIService.obtenerMedicamentosPaginadosConFiltrosCantidadTotal(palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<void> asociarMedicamento(Medicamento? selectedMedicamento, Usuario? selectedResidente) async {
    await APIService.postAsociarMedicamento(selectedMedicamento, selectedResidente, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<Medicamento>?> listaMedicamentosAsociados(int paginaActual, int elementosPorPagina, String cedulaResidente, String? palabraClave) async {
    String medicamentos =
        await APIService.fetchMedicamentosAsociados(paginaActual, elementosPorPagina, cedulaResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(medicamentos);
    return Medicamento.fromJsonList(jsonList);
  }

  Future<int?> obtenerMedicamentosAsociadosPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave) async {
    String cantidadTotal =
        await APIService.obtenerMedicamentosAsociadosPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<void> registrarPrescripcion(Medicamento? selectedMedicamento, Usuario? selectedResidente, int cantidad, String descripcion, int notificacionStock, int prescripcionCronica,
      int duracion, int frecuencia, TimeOfDay? hora_comienzo) async {
    String horaSeleccionadaString = '${hora_comienzo!.hour}:${hora_comienzo!.minute.toString().padLeft(2, '0')}';
    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();
    await APIService.postPrescripcion(selectedMedicamento, selectedResidente, geriatra?.ci, cantidad, descripcion, notificacionStock, prescripcionCronica, duracion, frecuencia,
        horaSeleccionadaString, geriatra?.getToken());
  }

  Future<List<PrescripcionDeMedicamento>> obtenerPrescripcionesMedicamentosPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String prescripcionesMedicamentos = await APIService.obtenerPrescripcionesMedicamentosPaginadosConfiltros(
        paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(prescripcionesMedicamentos);
    return PrescripcionDeMedicamento.listaVistaPrevia(jsonList);
  }

  Future<int?> obtenerPrescripcionesMedicamentosPaginadosConfiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String cantidadTotal = await APIService.obtenerPrescripcionesMedicamentosPaginadosConfiltrosCantidadTotal(
        fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<List<RegistroMedicacionConPrescripcion>> obtenerRegistrosMedicamentosConPrescripcion(DateTime? fechaFiltro, String? ciFiltro) async {
    String registros = await APIService.obtenerRegistrosMedicamentosConPrescripcion(fechaFiltro, ciFiltro, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(registros);
    return RegistroMedicacionConPrescripcion.listaVistaPrevia(jsonList);
  }

  Future<void> procesarMedicacion(RegistroMedicacionConPrescripcion? selectedRegistro) async {
    String horaDeRealizacion = '${selectedRegistro?.horaDeRealizacion!.hour}:${selectedRegistro?.horaDeRealizacion!.minute.toString().padLeft(2, '0')}';
    String fechaRealizacion = DateFormat('yyyy-MM-dd').format(selectedRegistro!.fecha_de_realizacion);

    await APIService.procesarMedicacion(selectedRegistro.idRegistroMedicacionConPrescripcion, horaDeRealizacion, fechaRealizacion, selectedRegistro.cantidadDada,
        selectedRegistro.descripcion, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<RegistroMedicacionConPrescripcion>> obtenerMedicacionesPeriodicasPaginadasConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String medicamentos = await APIService.obtenerMedicacionesPeriodicasPaginadasConfiltros(
        paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(medicamentos);
    return RegistroMedicacionConPrescripcion.listaVistaPrevia(jsonList);
  }

  Future<int?> obtenerMedicacionesPeriodicasPaginadasConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String cantidadTotal = await APIService.obtenerMedicacionesPeriodicasPaginadasConFiltrosCantidadTotal(
        fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<List<PrescripcionDeMedicamento>?> obtenerPrescripcionesActivasPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, String? ciResidente, String? palabraClave) async {
    String prescripciones = await APIService.obtenerPrescripcionesActivasPaginadosConfiltros(
        paginaActual, elementosPorPagina, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(prescripciones);
    return PrescripcionDeMedicamento.listaVistaPrevia(jsonList);
  }

  Future<int?> obtenerPrescripcionesActivasPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave) async {
    String cantidadTotal =
        await APIService.obtenerPrescripcionesActivasPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<void> cargarStock(int? id_prescripcion, int stock, int stockNotificacion, String? ciFamiliar, int stockAnterior) async {
    await APIService.cargarStock(id_prescripcion, stock, stockNotificacion, ciFamiliar, stockAnterior, Fachada.getInstancia()?.getUsuario()!.getToken());
  }

  Future<void> notificarStock(int idRegistroMedicacionConPrescripcion) async {
    await APIService.notificarStock(idRegistroMedicacionConPrescripcion, Fachada.getInstancia()?.getUsuario()!.getToken());
  }
}
