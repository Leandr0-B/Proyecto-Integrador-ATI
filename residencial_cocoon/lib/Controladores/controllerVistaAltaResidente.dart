import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaAltaResidente {
  //Atributos
  Function(String mensaje) mostrarMensaje;

  //Constructor
  ControllerVistaAltaResidente({required this.mostrarMensaje}) {}

  //Funciones
  Future<void> altaUsuario(String ci, String nombre, int administrador,
      List<int> selectedRoles, List<int> selectedSucursales) async {
    try {
      await Fachada.getInstancia()?.altaUsuario(
          ci, nombre, administrador, selectedRoles, selectedSucursales);
    } on AltaUsuarioException catch (ex) {
      mostrarMensaje(ex.mensaje);
    }
  }

  bool controlAlta(Familiar familiar, List<Familiar> lista) {
    if (lista.contains(familiar)) {
      mostrarMensaje(
          "Ya hay un familiar con el documento identificador ingresado.");
      return false;
    }
    return true;
  }
}
