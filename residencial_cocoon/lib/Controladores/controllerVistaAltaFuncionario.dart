import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaAltaFuncionario {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  List<Rol>? _roles;
  List<Sucursal>? _sucursales;

  //Constructor
  ControllerVistaAltaFuncionario({
    required this.mostrarMensaje,
  });

  //Funciones
  Future<List<Rol>?> listaRoles() async {
    if (this._roles == null) {
      this._roles = await Fachada.getInstancia()?.listaRoles();
    }
    return this._roles;
  }

  Future<List<Sucursal>?> listaSucursales() async {
    if (this._sucursales == null) {
      this._sucursales = await Fachada.getInstancia()?.listaSucursales();
    }
    return this._sucursales;
  }

  Future<void> altaUsuario(String ci, String nombre, int administrador,
      List<int> selectedRoles, List<int> selectedSucursales) async {
    try {
      await Fachada.getInstancia()?.altaUsuario(
          ci, nombre, administrador, selectedRoles, selectedSucursales);
    } on AltaUsuarioException catch (ex) {
      mostrarMensaje(ex.mensaje);
    }
  }
}
