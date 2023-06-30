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
    String cantidadNotificacionesSinLeer = await APIService.fetchNotificacionesSinLeer(Fachada.getInstancia()?.getUsuario()!.getToken());
    var decode = jsonDecode(cantidadNotificacionesSinLeer);
    return decode['cantidad'];
  }

  Future<List<Notificacion>?> obtenerUltimasNotificaciones() async {
    String notificaciones = await APIService.fetchUltimasNotificaciones(Fachada.getInstancia()?.getUsuario()!.getToken());

    List<dynamic> jsonList = jsonDecode(notificaciones);
    return Notificacion.listaVistaPrevia(jsonList);
  }

  void marcarNotificacionComoLeida(Notificacion notificacion) {
    APIService.marcarNotificacionComoLeida(notificacion, Fachada.getInstancia()?.getUsuario()!.getToken());
  }

  Future<List<Notificacion>?> obtenerNotificacionesPaginadasConfiltros(int page, int limit, DateTime? desde, DateTime? hasta, String? palabras) async {
    String notificaciones = await APIService.obtenerNotificacionesPaginadasConFiltros(page, limit, desde, hasta, palabras, Fachada.getInstancia()?.getUsuario()!.getToken());
    List<dynamic> jsonList = jsonDecode(notificaciones);
    return Notificacion.listaVistaPrevia(jsonList);
  }

  Future<int?> obtenerNotificacionesPaginadasConFiltrosCantidadTotal(DateTime? desde, DateTime? hasta, String? palabras) async {
    String cantidadTotal = await APIService.obtenerNotificacionesPaginadasConFiltrosCantidadTotal(desde, hasta, palabras, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }

  Future<int?> obtenerNotificacionesPaginadasCantidadTotal() async {
    String cantidadTotal = await APIService.obtenerNotificacionesPaginadasCantidadTotal(Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }
}
