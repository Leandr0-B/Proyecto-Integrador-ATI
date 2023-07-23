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

  Future<List<Medicamento>?> obtenerMedicamentosPaginadosConFiltrosSinAsociar(int paginaActual, int elementosPorPagina, String cedulaResidente, String? palabraClave) async {
    String medicamentos = await APIService.obtenerMedicamentosPaginadosConFiltrosSinAsociar(
        paginaActual, elementosPorPagina, cedulaResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(medicamentos);
    return Medicamento.fromJsonList(jsonList);
  }

  Future<int?> obtenerMedicamentosPaginadosConFiltrosSinAsociarCantidadTotal(String? ciResidente, String? palabraClave) async {
    String cantidadTotal =
        await APIService.obtenerMedicamentosPaginadosConFiltrosSinAsociarCantidadTotal(ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<void> asociarMedicamento(Medicamento? selectedMedicamento, Usuario? selectedResidente, int stock, int stockNotificacion) async {
    await APIService.postAsociarMedicamento(selectedMedicamento, selectedResidente, stock, stockNotificacion, Fachada.getInstancia()?.getUsuario()?.getToken());
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

  Future<void> registrarPrescripcion(Medicamento? selectedMedicamento, Usuario? selectedResidente, int cantidad, String descripcion, DateTime? fecha_desde, DateTime? fecha_hasta,
      int frecuencia, TimeOfDay? hora_comienzo) async {
    String horaSeleccionadaString = '${hora_comienzo!.hour}:${hora_comienzo!.minute.toString().padLeft(2, '0')}';
    String fecha_desde_formateada = DateFormat('yyyy-MM-dd').format(fecha_desde!);
    String fecha_hasta_formateada = DateFormat('yyyy-MM-dd').format(fecha_hasta!);
    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();
    await APIService.postPrescripcion(selectedMedicamento, selectedResidente, geriatra?.ci, cantidad, descripcion, fecha_desde_formateada, fecha_hasta_formateada, frecuencia,
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
}
