import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

abstract class IvistaAltaFuncionario {
  void mostrarMensaje(String mensaje);
  Future<void> altaUsuarioFuncionario(String ci, String nombre,
      int administrador, List<int> roles, List<int> sucursales);
  void limpiarDatos();
  Future<List<Sucursal>?> getSucursales();
  Future<List<Rol>?> getRoles();
}
