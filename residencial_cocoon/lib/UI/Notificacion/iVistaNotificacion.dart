import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';

abstract class IVistaNotificacion {
  void obtenerNotificacionesPaginadasConfiltros();
  void obtenerNotificacionesPaginadas();
  void obtenerNotificacionesPaginadasBotonFiltrar();
  void mostrarPopUp(Notificacion notificacion);
  void marcarNotificacionComoLeida(Notificacion notificacion);
  void mostrarMensaje(String mensaje);
}
