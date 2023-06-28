import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';

abstract class IVistaNotificacion {
  void obtenerUltimasNotificaciones();
  void mostrarPopUp(Notificacion notificacion);
  void marcarNotificacionComoLeida(Notificacion notificacion);
}
