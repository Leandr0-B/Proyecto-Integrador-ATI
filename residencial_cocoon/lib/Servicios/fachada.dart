import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/servicioUsuario.dart';

class Fachada {
  //Atributos
  static Fachada? _instancia;
  ServicioUsuario? _servicioUsuario;

  //Constructor
  Fachada._() {
    _servicioUsuario = ServicioUsuario();
  }

  static Fachada? getInstancia() {
    _instancia ??= Fachada._();
    return _instancia;
  }

  //Funciones
  //Usuario
  Future<Usuario?> login(String ci, String clave) async {
    return await _servicioUsuario?.login(ci, clave);
  }
}
