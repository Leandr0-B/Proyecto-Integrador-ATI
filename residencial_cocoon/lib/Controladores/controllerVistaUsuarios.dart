import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaUsuarios {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  List<Usuario>? _usuarios;

  //Constructor
  ControllerVistaUsuarios({
    required this.mostrarMensaje,
  });

  //Funciones
  Future<List<Usuario>?> obtenerUsuarios() async {
    if (_usuarios == null) {
      this._usuarios = await Fachada.getInstancia()?.obtenerUsuarios();
    }
    return this._usuarios;
  }
}
