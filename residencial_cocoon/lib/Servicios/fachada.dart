import 'package:residencial_cocoon/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/servicioUsuario.dart';

class Fachada {
  //Atributos
  static Fachada? _instancia;
  ServicioUsuario? _sUsuario;

  //Constructor
  Fachada._() {
    _sUsuario = ServicioUsuario();
  }

  static Fachada? getInstancia() {
    if (_instancia == null) {
      _instancia = Fachada._();
    }
    return _instancia;
  }

  //Funciones
  //Usuario
  Usuario? login(String ci, String clave) {
    return _sUsuario?.login(ci, clave);
  }
}
