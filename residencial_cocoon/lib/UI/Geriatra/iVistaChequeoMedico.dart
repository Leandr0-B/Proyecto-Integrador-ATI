import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaChequeoMedico {
  void mostrarMensaje(String mensaje);
  void limpiar();
  Future<void> altaChequeoMedico();
  Future<List<Usuario>?> listaResidentes(Sucursal? suc);
  Future<List<Sucursal>?> listaSucursales();
  Future<List<Control>?> listaControles();
}
