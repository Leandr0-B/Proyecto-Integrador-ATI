import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';

class Residente extends Rol {
  //Atributos
  List<Familiar> _familiares = [];

  //Constructor
  Residente(int idRol, String descripcion, this._familiares) : super.sinUsuario(idRol, descripcion);

  Residente.sinFamiliares(int idRol, String descripcion) : super.sinUsuario(idRol, descripcion);

  Residente.empty() : super.empty();

  //Funciones
  @override
  bool esResidente() {
    return true;
  }

  List<Familiar> getFamiliares() {
    return _familiares;
  }

  set familiares(List<Familiar> familiares) => _familiares = familiares;

  String obtenerTelefono() {
    String telefono = '';
    for (var fam in _familiares) {
      if (fam.contactoPrimario == 1) {
        telefono = fam.telefono;
      }
    }
    return telefono;
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "id_rol: $idRol, ";
    retorno += "descripcion: $descripcion, ";
    retorno += "usuario: ${usuario.ci} ${usuario.nombre}";
    retorno += "Familiares: $_familiares";
    return retorno;
  }
}
