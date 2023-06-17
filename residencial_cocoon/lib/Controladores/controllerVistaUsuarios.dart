import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaUsuarios {
  //Atributos
  Function(String mensaje) mostrarMensaje;

  //Constructor
  ControllerVistaUsuarios({
    required this.mostrarMensaje,
  });

  //Funciones
  Future<List<Usuario>?> obtenerUsuarios() async {
    return await Fachada.getInstancia()?.obtenerUsuarios();
  }
}
