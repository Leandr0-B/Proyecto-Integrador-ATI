import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaListaUsuario.dart';

class ControllerVistaListaUsuario {
  //Atributos
  List<Usuario>? _usuarios = [];
  IvistaListaUsuario? _vista;

  //Constructor
  ControllerVistaListaUsuario.empty();
  ControllerVistaListaUsuario(this._vista);

  //Funciones
  Future<List<Usuario>?> obtenerUsuarios() async {
    try {
      if (_usuarios!.isEmpty) {
        this._usuarios = await Fachada.getInstancia()?.obtenerUsuarios();
        if (this._usuarios == null || this._usuarios!.isEmpty) {
          _vista?.mostrarMensajeError("No hay usuarios cargados en el sistema");
        }
      }
      return this._usuarios;
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }
}
