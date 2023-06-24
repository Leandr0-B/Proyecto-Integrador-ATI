import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaSalidaMedica {
  //Atributos
  Function(String mensaje) mostrarMensaje;

  //Constructor
  ControllerVistaSalidaMedica({
    required this.mostrarMensaje,
  });

  //Funciones
  Future<List<Usuario>?> listaResidentes() async {
    return await Fachada.getInstancia()?.obtenerUsuarios();
  }
}
