import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaAltaFuncionario.dart';

class ControllerVistaAltaFuncionario {
  //Atributos
  List<Rol>? _roles;
  List<Sucursal>? _sucursales;
  IvistaAltaFuncionario? _vista;

  //Constructor
  ControllerVistaAltaFuncionario.empty();
  ControllerVistaAltaFuncionario(this._vista);

  //Funciones
  Future<List<Rol>?> listaRoles() async {
    try {
      if (this._roles == null) {
        this._roles = await Fachada.getInstancia()?.listaRoles();
      }
      return this._roles;
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

  Future<List<Sucursal>?> listaSucursales() async {
    try {
      if (this._sucursales == null) {
        this._sucursales = await Fachada.getInstancia()?.listaSucursales();
      }
      return this._sucursales;
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

  Future<void> altaUsuario(String ci, String nombre, int administrador,
      List<int> selectedRoles, List<int> selectedSucursales) async {
    try {
      await Fachada.getInstancia()?.altaUsuario(
          ci, nombre, administrador, selectedRoles, selectedSucursales);
    } on AltaUsuarioException catch (ex) {
      _vista?.mostrarMensaje(ex.mensaje);
      _vista?.limpiarDatos();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on Exception catch (ex) {
      _vista?.mostrarMensajeError(ex.toString());
    }
  }

  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }
}
