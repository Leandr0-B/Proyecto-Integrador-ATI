import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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

  Future<List<Notificacion>> obtenerUltimasNotificaciones() async {
    return await Fachada.getInstancia()?.obtenerUltimasNotificaciones() ?? [];
  }

  void marcarNotificacionComoLeida(Notificacion notificacion) {
    if (notificacion.leida == false) {
      Fachada.getInstancia()?.marcarNotificacionComoLeida(notificacion);
      notificacion.marcarNotificacionComoLeida();
    }
  }

  void escucharNotificacionEnPrimerPlano() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _vistaNotificacion?.obtenerUltimasNotificaciones();
      }
    });
  }
}
