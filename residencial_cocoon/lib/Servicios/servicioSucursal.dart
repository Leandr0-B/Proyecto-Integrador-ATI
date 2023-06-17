import 'dart:convert';

import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioSucursal {
  //Atributos

  //Constructor
  ServicioSucursal();

  //Funciones
  Future<List<Sucursal>?> listaSucursales() async {
    String sucursal = await APIService.fetchSucursales(
        Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList =
        jsonDecode(sucursal); // convert the JSON text to a List
    return Sucursal.fromJsonList(jsonList);
  }
}
