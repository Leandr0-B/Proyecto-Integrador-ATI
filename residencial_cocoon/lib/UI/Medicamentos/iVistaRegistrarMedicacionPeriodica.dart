import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/registroMedicacionConPrescripcion.dart';

abstract class IvistaRegistrarMedicacionPeriodica {
  void mostrarMensaje(String mensaje);
  void mostrarMensajeError(String mensaje);
  void limpiar();
  void cerrarSesion();
  void cambiarColor();
}
