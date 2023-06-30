import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

abstract class IvistaAltaResidente {
  void mostrarMensaje(String mensaje);
  void limpiarDatos();
  Future<List<Sucursal>?> getSucursales();
  Future<void> crearUsuario();
}
