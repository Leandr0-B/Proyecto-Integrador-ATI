import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaListaUsuario.dart';

class ControllerVistaListaUsuario {
  //Atributos
  List<Usuario>? _usuarios = [];
  IvistaListaUsuario? _vistaLista;

  //Constructor
  ControllerVistaListaUsuario.empty();
  ControllerVistaListaUsuario(this._vistaLista);

  //Funciones
  Future<List<Usuario>?> obtenerUsuarios() async {
    if (_usuarios!.isEmpty) {
      this._usuarios = await Fachada.getInstancia()?.obtenerUsuarios();
      if (this._usuarios == null || this._usuarios!.isEmpty) {
        _vistaLista?.mostrarMensaje("No hay usuarios cargados en el sistema");
      }
    }
    return this._usuarios;
  }
}
