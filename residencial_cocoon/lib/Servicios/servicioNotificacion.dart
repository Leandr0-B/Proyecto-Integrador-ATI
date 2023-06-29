import 'dart:convert';

import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';
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

  Future<List<Notificacion>?> obtenerUltimasNotificaciones() async {
    String notificaciones = await APIService.fetchUltimasNotificaciones(
        Fachada.getInstancia()?.getUsuario()!.getToken());

    List<dynamic> jsonList = jsonDecode(notificaciones);
    return Notificacion.listaVistaPrevia(jsonList);
  }

  void marcarNotificacionComoLeida(Notificacion notificacion) {
    APIService.marcarNotificacionComoLeida(
        notificacion, Fachada.getInstancia()?.getUsuario()!.getToken());
  }

  Future<List<Notificacion>?> obtenerNotificacionesPaginadas(
      int page, int limit) async {
    String notificaciones = await APIService.obtenerNotificacionesPaginadas(
        page, limit, Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList = jsonDecode(notificaciones);
    return Notificacion.listaVistaPrevia(jsonList);
  }
}
