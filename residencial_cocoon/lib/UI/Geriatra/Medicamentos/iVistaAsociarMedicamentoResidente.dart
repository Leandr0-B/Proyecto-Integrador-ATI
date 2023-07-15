import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

abstract class IvistaAsociarMedicamento {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiar();
  Future<List<Usuario>?> listaResidentes();
  Future<List<Sucursal>?> listaSucursales();
  void obtenerMedicamentosPaginadosConfiltros();
  void obtenerMedicamentosPaginadosBotonFiltrar();
  Future<void> asociarMedicamento();
  void cerrarSesion();
}
