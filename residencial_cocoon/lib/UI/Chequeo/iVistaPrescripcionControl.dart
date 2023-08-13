import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaPrescripcionControl {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiar();
  void limpiarControl();
  Future<List<Usuario>?> listaResidentes();
  Future<List<Sucursal>?> listaSucursales();
  void obtenerControles();
  Future<void> altaPrescripcion();
  void cerrarSesion();
}
