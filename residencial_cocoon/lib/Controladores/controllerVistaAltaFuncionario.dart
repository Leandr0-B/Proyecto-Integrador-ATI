import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
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

  Future<void> altaUsuario(String ci, String nombre, int administrador, List<int> selectedRoles, List<int> selectedSucursales, String apellido, String telefono, String email,
      DateTime? fechaNacimiento) async {
    nombre = _capitalize(nombre);
    apellido = _capitalize(apellido);
    try {
      if (_controles(email, fechaNacimiento)) {
        await Fachada.getInstancia()?.altaUsuario(ci, nombre, administrador, selectedRoles, selectedSucursales, apellido, telefono, email, fechaNacimiento);
      }
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

  bool _controles(String email, DateTime? fechaNacimiento) {
    if (!Usuario.esEmailValido(email)) {
      _vista?.mostrarMensajeError("El email no tiene el formato correcto.");
      return false;
    }
    if (fechaNacimiento == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar la fecha de nacimiento");
      return false;
    }
    return true;
  }

  String _capitalize(String text) {
    List<String> words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        words[i] = word[0].toUpperCase() + word.substring(1);
      }
    }
    return words.join(' ');
  }
}
