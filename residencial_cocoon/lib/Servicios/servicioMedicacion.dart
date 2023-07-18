import 'dart:convert';

import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
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

  Future<List<Medicamento>?> listaMedicamentos(int paginaActual, int elementosPorPagina, String cedulaResidente, String palabraClave) async {
    String medicamentos = await APIService.fetchMedicamentos(paginaActual, elementosPorPagina, cedulaResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(medicamentos);
    return Medicamento.fromJsonList(jsonList);
  }

  Future<int?> obtenerMedicamentosPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave) async {
    String cantidadTotal = await APIService.obtenerMedicamentosPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<void> asociarMedicamento(Medicamento? selectedMedicamento, Usuario? selectedResidente, int stock, int stockNotificacion) async {
    await APIService.postAsociarMedicamento(selectedMedicamento, selectedResidente, stock, stockNotificacion, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<Medicamento>?> listaMedicamentosAsociados(int paginaActual, int elementosPorPagina, String cedulaResidente, String palabraClave) async {
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
}
