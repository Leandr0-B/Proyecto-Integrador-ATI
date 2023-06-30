import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IVistaLogin {
  void mostrarMensaje(String mensaje);
  void ingreso(Usuario? usuario);
}
