import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaVisitaMedicaExterna {
  void mostrarMensaje(String mensaje);
  void limpiar();
  Future<void> altaVisitaMedicaExt();
  Future<List<Usuario>?> listaResidentes(Sucursal? suc);
  Future<List<Sucursal>?> listaSucursales();
}
