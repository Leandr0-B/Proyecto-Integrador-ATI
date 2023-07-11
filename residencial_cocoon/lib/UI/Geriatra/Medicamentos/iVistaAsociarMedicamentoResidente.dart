import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaPrescripcionMedicamento {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiar();
  Future<List<Usuario>?> listaResidentes();
  Future<List<Sucursal>?> listaSucursales();
  Future<List<Medicamento>?> listaMedicamentos();
  Future<void> asosiarMedicamento();
  void cerrarSesion();
}
