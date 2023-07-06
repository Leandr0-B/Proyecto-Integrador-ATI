import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Notificacion/iVistaNotificacion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';

class ControllerVistaNotificacion {
  String? token = null;
  IVistaNotificacion? _vistaNotificacion;
  //Atributos

  //Constructor
  ControllerVistaNotificacion.empty();
  ControllerVistaNotificacion(this._vistaNotificacion);

  void marcarNotificacionComoLeida(Notificacion notificacion) {
    try {
      if (notificacion.leida == false) {
        Fachada.getInstancia()?.marcarNotificacionComoLeida(notificacion);
        notificacion.marcarNotificacionComoLeida();
      }
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

  void escucharNotificacionEnPrimerPlano() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _vistaNotificacion?.obtenerNotificacionesPaginadasConfiltros();
      }
    });
  }

  Future<int> calcularTotalPaginas(
      itemsPerPage, DateTime? desde, DateTime? hasta, String? palabras) async {
    try {
      int totalNotificaciones = await Fachada.getInstancia()
              ?.obtenerNotificacionesPaginadasConFiltrosCantidadTotal(
                  desde, hasta, palabras) ??
          0;
      return (totalNotificaciones / itemsPerPage).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  Future<List<Notificacion>> obtenerNotificacionesPaginadasConFiltros(int page,
      int limit, DateTime? desde, DateTime? hasta, String? palabras) async {
    try {
      return await Fachada.getInstancia()
              ?.obtenerNotificacionesPaginadasConfiltros(
                  page, limit, desde, hasta, palabras) ??
          [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  void _cerrarSesion(String mensaje) {
    _vistaNotificacion?.mostrarMensaje(mensaje);
    _vistaNotificacion?.cerrarSesion();
  }
}
