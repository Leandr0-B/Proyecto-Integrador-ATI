import 'dart:convert';

import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioNotificacion {
  //Atributos

  //Constructor
  ServicioNotificacion();

  //Funciones
  Future<int> cantidadNotifiacionesSinLeer() async {
    String cantidadNotificacionesSinLeer =
        await APIService.fetchNotificacionesSinLeer(
            Fachada.getInstancia()?.getUsuario()!.getToken());
    var decode = jsonDecode(cantidadNotificacionesSinLeer);
    return decode['cantidad'];
  }
}
