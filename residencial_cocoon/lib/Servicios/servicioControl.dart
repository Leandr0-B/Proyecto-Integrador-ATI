import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioControl {
  //Atributos

  //Constructor
  ServicioControl();

  //Funciones
  Future<List<Control>?> listaControles() async {
    String controles = await APIService.fetchControles(
        Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList =
        jsonDecode(controles); // convert the JSON text to a List
    return Control.fromJsonList(jsonList);
  }

  Future<void> altaChequeoMedico(
      Usuario? selectedResidente,
      List<Control?> selectedControles,
      DateTime? fecha,
      String descripcion) async {
    DateTime fecha_sin_hora = DateTime(fecha!.year, fecha!.month, fecha!.day);
    String fecha_desde_formateada =
        DateFormat('yyyy-MM-dd').format(fecha_sin_hora);
    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();

    List<Map<String, dynamic>> selectedControlesJson =
        selectedControles.map((control) => control!.toJson()).toList();

    await APIService.postChequeoMedico(
        geriatra?.getToken(),
        selectedResidente?.ci,
        geriatra?.ci,
        descripcion,
        fecha_desde_formateada,
        selectedControlesJson);
  }

  List<int> _convertirControles(List<Control> controles) {
    List<int> aux = [];
    controles.forEach((control) {
      aux.add(control.id_control);
    });
    return aux;
  }
}
