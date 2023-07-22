import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaListaUsuario {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void cerrarSesion();
}
