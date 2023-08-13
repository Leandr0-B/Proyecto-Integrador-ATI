import 'dart:convert';

import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
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

  Future<void> altaChequeoMedico(Usuario? selectedResidente, List<Control?> selectedControles, DateTime? fecha, String descripcion) async {
    DateTime fecha_sin_hora = DateTime(fecha!.year, fecha!.month, fecha!.day);
    String fecha_desde_formateada = DateFormat('yyyy-MM-dd').format(fecha_sin_hora);
    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();

    List<Map<String, dynamic>> selectedControlesJson = selectedControles.map((control) => control!.toJson()).toList();

    await APIService.postChequeoMedico(geriatra?.getToken(), selectedResidente?.ci, geriatra?.ci, descripcion, fecha_desde_formateada, selectedControlesJson);
  }

  List<int> _convertirControles(List<Control> controles) {
    List<int> aux = [];
    controles.forEach((control) {
      aux.add(control.id_control);
    });
    return aux;
  }

  Future<void> registrarControl(String nombreControl, String unidadControl, int compuestoControl, int valorReferenciaMinimo, int valorReferenciaMaximo,
      int maximoValorReferenciaMinimo, int maximoValorReferenciaMaximo) async {
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
}
