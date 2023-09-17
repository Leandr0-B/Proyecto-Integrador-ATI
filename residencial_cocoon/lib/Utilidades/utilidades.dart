import 'dart:async';

import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/registroControlConPrescripcion.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'dart:html' as html;
import 'package:residencial_cocoon/UI/Login/vistaLogin.dart';
import 'package:residencial_cocoon/Utilidades/auxRegistro.dart';

class Utilidades {
  static void cerrarSesion(BuildContext context) {
    Fachada.getInstancia()?.setUsuario(null);
    html.window.localStorage.remove('usuario');
    Navigator.pushReplacementNamed(context, VistaLogin.id);
  }

  static IconData obtenerIcono(String icono) {
    switch (icono) {
      case 'procesado':
        return Icons.check_circle_outline;
      case 'vencido':
        return Icons.watch_later_outlined;
      case 'enHora':
        return Icons.circle_notifications_outlined;
      case 'porVencer':
        return Icons.warning_amber_rounded;
      default:
        return Icons.live_help_rounded;
    }
  }

  static int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) {
      return -1;
    } else if (time1.hour > time2.hour) {
      return 1;
    } else {
      // Las horas son iguales, comparar los minutos
      if (time1.minute < time2.minute) {
        return -1;
      } else if (time1.minute > time2.minute) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  static bool _diferencia15Minutos(TimeOfDay time1, TimeOfDay time2) {
    int minutes1 = time1.hour * 60 + time1.minute;
    int minutes2 = time2.hour * 60 + time2.minute;

    int diferencia = (minutes1 - minutes2).abs();

    return diferencia <= 15;
  }

  static AuxRegistro colorDelRegistro(RegistroControlConPrescripcion registro) {
    AuxRegistro aux = AuxRegistro.empty();
    if (registro.procesada == 1) {
      aux.tipoIcono = "procesado";
      aux.color = Color.fromARGB(150, 42, 119, 44);
      return aux;
    } else if (registro.fecha_pactada.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      aux.tipoIcono = "vencido";
      aux.color = Color.fromARGB(120, 145, 21, 12);
      return aux;
    } else {
      final currentTime = TimeOfDay.now();
      switch (_compareTimeOfDay(registro.hora_pactada, currentTime)) {
        case 0:
          aux.tipoIcono = "enHora";
          aux.color = Colors.orange;
          return aux;
        case -1:
          aux.tipoIcono = "vencido";
          aux.color = Color.fromARGB(120, 145, 21, 12);
          return aux;
        case 1:
          if (_diferencia15Minutos(registro.hora_pactada, currentTime)) {
            aux.tipoIcono = "porVencer";
            aux.color = Color.fromARGB(150, 235, 214, 29);
            return aux;
          } else {
            aux.tipoIcono = "";
            aux.color = Colors.white;
            return aux;
          }
        default:
          aux.tipoIcono = "";
          aux.color = Colors.white;
          return aux;
      }
    }
  }

  static Future<DateTime?> selectFechaConTope(BuildContext context, DateTime? fecha) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fecha ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    return picked;
  }

  static Future<DateTime?> selectFechaSinTope(BuildContext context, DateTime? fecha) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fecha ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    return picked;
  }

  static Future<DateTime?> selectFechaNacimiento(BuildContext context, DateTime? fecha) async {
    final DateTime now = DateTime.now();
    //final DateTime initialDate = now.subtract(Duration(days: 16 * 365)); // Resta 18 años en días
    DateTime initialDate = DateTime(now.year - 16, now.month, now.day);
    final DateTime lastDate = now.subtract(Duration(days: 120 * 365)); // Resta 120 años en días

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fecha ?? initialDate,
      firstDate: lastDate,
      lastDate: initialDate,
    );
    return picked;
  }

  static Future<TimeOfDay?> selectHora(BuildContext context, TimeOfDay? hora) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: hora ?? TimeOfDay.now(),
    );
    return picked;
  }
}
