import 'dart:convert';

import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/prescripcionDeControl.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/registroControlConPrescripcion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/datosGrafica.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioControl {
  //Atributos

  //Constructor
  ServicioControl();

  //Funciones
  Future<List<Control>?> listaControles() async {
    String controles = await APIService.fetchControles(Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList = jsonDecode(controles); // convert the JSON text to a List
    return Control.fromJsonListPrescripcion(jsonList);
  }

  Future<void> altaChequeoMedico(Usuario? selectedResidente, List<Control?> selectedControles, DateTime? fecha, TimeOfDay? hora, String descripcion) async {
    DateTime fecha_sin_hora = DateTime(fecha!.year, fecha!.month, fecha!.day);
    String fecha_desde_formateada = DateFormat('yyyy-MM-dd').format(fecha_sin_hora);
    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();

    List<Map<String, dynamic>> selectedControlesJson = Control.listaParaChequeo(selectedControles);

    String horaSeleccionadaString = '${hora!.hour}:${hora!.minute.toString().padLeft(2, '0')}';

    String fechaHora = fecha_desde_formateada + " " + horaSeleccionadaString;

    await APIService.postChequeoMedico(geriatra?.getToken(), selectedResidente?.ci, geriatra?.ci, descripcion, fechaHora, selectedControlesJson);
  }

  List<int> _convertirControles(List<Control> controles) {
    List<int> aux = [];
    controles.forEach((control) {
      aux.add(control.id_control);
    });
    return aux;
  }

  Future<void> registrarControl(String nombreControl, String unidadControl, int compuestoControl, double valorReferenciaMinimo, double valorReferenciaMaximo,
      double maximoValorReferenciaMinimo, double maximoValorReferenciaMaximo) async {
    await APIService.registrarControl(nombreControl, unidadControl, compuestoControl, valorReferenciaMinimo, valorReferenciaMaximo, maximoValorReferenciaMinimo,
        maximoValorReferenciaMaximo, Fachada.getInstancia()?.getUsuario()!.getToken());
  }

  Future<void> registrarPrescripcionControl(Usuario? selectedResidente, Sucursal? selectedSucursal, List<Control?> selectedControles, TimeOfDay? horaComienzo, String descripcion,
      int frecuencia, int prescripcionCronica, int duracion) async {
    String horaSeleccionadaString = '${horaComienzo!.hour}:${horaComienzo!.minute.toString().padLeft(2, '0')}';
    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();
    List<Map<String, dynamic>> listaControles = Control.listaParaApi(selectedControles);
    await APIService.registrarPrescripcionControl(
        selectedResidente, geriatra?.ci, selectedSucursal, listaControles, horaSeleccionadaString, descripcion, frecuencia, prescripcionCronica, duracion, geriatra?.getToken());
  }

  Future<List<RegistroControlConPrescripcion>?> obtenerRegistrosPrescripcionesControlesPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String prescripciones = await APIService.obtenerRegistrosPrescripcionesControlesPaginadosConfiltros(
        paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(prescripciones);
    return RegistroControlConPrescripcion.listaVistaPrevia(jsonList);
  }

  Future<int?> obtenerRegistrosPrescripcionesControlesPaginadosConfiltrosCantidadTotal(
      DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String cantidadTotal = await APIService.obtenerRegistrosPrescripcionesControlesPaginadosConfiltrosCantidadTotal(
        fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<List<PrescripcionDeControl>?> obtenerPrescripcionesControlesPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String prescripciones = await APIService.obtenerPrescripcionesControlesPaginadosConfiltros(
        paginaActual, elementosPorPagina, fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(prescripciones);
    return PrescripcionDeControl.listaVistaPrevia(jsonList);
  }

  Future<int?> obtenerPrescripcionesControlesPaginadosConfiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave) async {
    String cantidadTotal = await APIService.obtenerPrescripcionesControlesPaginadosConfiltrosCantidadTotal(
        fechaDesde, fechaHasta, ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<List<RegistroControlConPrescripcion>?> obtenerRegistrosControlesConPrescripcion(DateTime? fechaFiltro, String? ciFiltro) async {
    String prescripciones = await APIService.obtenerRegistrosControlesConPrescripcion(fechaFiltro, ciFiltro, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(prescripciones);
    return RegistroControlConPrescripcion.listaVistaPrevia(jsonList);
  }

  Future<void> procesarControl(RegistroControlConPrescripcion registro) async {
    List<Map<String, dynamic>> listaControles = Control.listaParaRegistro(registro.controles());
    String horaSeleccionadaString = '${registro.hora_de_realizacion!.hour}:${registro.hora_de_realizacion!.minute.toString().padLeft(2, '0')}';
    String fechaRealizacion = DateFormat('yyyy-MM-dd').format(registro.fecha_realizada);
    await APIService.procesarControl(registro, listaControles, fechaRealizacion, horaSeleccionadaString, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<DatosGrafica>> datosGrafica(String ciResidente) async {
    String datos = await APIService.datosGrafica(ciResidente, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(datos);
    return DatosGrafica.listaJson(jsonList);
  }
}
