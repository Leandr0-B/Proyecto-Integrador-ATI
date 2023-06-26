import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/tipoNotificacion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class Notificacion {
  //Atributos
  int _idNotificacion = 0;
  String _titulo = "";
  String _mensaje = "";
  DateTime _fecha = DateTime(0);
  bool _leida = false;
  TipoNotificacion _tipoNotificacion = TipoNotificacion.empty();
  Usuario _usuarioEnvia = Usuario.empty();

  //Constructor
  Notificacion(this._idNotificacion, this._titulo, this._mensaje, this._fecha,
      this._leida, this._tipoNotificacion, this._usuarioEnvia);

  // factory Notificacion.fromJson(Map<String, dynamic> json) {
  //   return Notificacion(json['id_sucursal'], json['nombre'], json['direccion']);
  // }

  //Get set
  int get idNotificacion => _idNotificacion;
  set idNotificacion(int value) => _idNotificacion = value;

  String get titulo => _titulo;
  set titulo(String value) => _titulo = value;

  String get mensaje => _mensaje;
  set mensaje(String value) => _mensaje = value;

  DateTime get fecha => _fecha;
  set fecha(DateTime value) => _fecha = value;

  bool get leida => _leida;
  set leida(bool value) => _leida = value;

  TipoNotificacion get tipoNotificacion => _tipoNotificacion;
  set tipoNotificacion(TipoNotificacion value) => _tipoNotificacion = value;

  Usuario get usuarioEnvia => _usuarioEnvia;
  set usuarioEnvia(Usuario value) => _usuarioEnvia = value;

  // static List<Notificacion> fromJsonList(List<dynamic> jsonList) {
  //   return jsonList
  //       .cast<Map<String, dynamic>>()
  //       .map<Notificacion>((json) => Notificacion.fromJson(json))
  //       .toList();
  // }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "idNotificacion: $idNotificacion, ";
    retorno += "titulo: $titulo, ";
    retorno += "_mensaje: $mensaje";
    retorno += "fecha: $fecha";
    retorno += "leida: $leida";
    retorno += "tipoNotificacion: $tipoNotificacion";
    retorno += "usuarioEnvia: $usuarioEnvia";
    return retorno;
  }
}
