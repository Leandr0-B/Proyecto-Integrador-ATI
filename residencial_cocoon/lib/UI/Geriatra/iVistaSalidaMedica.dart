import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaSalidaMedica {
  void mostrarMensaje(String mensaje);
  void limpiar();
  Future<void> altaSalidaMedica();
  Future<List<Usuario>?> listaResidentes();
  Future<List<Sucursal>?> listaSucursales();
}
