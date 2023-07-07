import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

abstract class IvistaAltaResidente {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiarDatos();
  void limpiarDatosFamiliar();
  Future<List<Sucursal>?> getSucursales();
  Future<void> crearUsuario();
  void cerrarSesion();
}
