import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaAltaUsuario {
  //Atributos
  Function(String mensaje) mostrarMensaje;

  //Constructor
  ControllerVistaAltaUsuario({
    required this.mostrarMensaje,
  });

  //Funciones
  Future<List<Rol>?> listaRoles() async {
    return await Fachada.getInstancia()?.listaRoles();
  }

  Future<List<Sucursal>?> listaSucursales() async {
    return await Fachada.getInstancia()?.listaSucursales();
  }

  Future<void> altaUsuario(String ci, String nombre, int administrador,
      List<int> selectedRoles, List<int> selectedSucursales) async {}
}
