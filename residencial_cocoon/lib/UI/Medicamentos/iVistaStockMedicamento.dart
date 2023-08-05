import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaStockMedicamento {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiar();
  Future<void> cargarStock();
  void cerrarSesion();
}
