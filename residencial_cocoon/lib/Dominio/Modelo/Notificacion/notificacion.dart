import 'package:intl/intl.dart';
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

  factory Notificacion.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario usuario = Usuario.empty();
    TipoNotificacion tipoNotificacion = TipoNotificacion.empty();

    usuario.ci = json['ci_envia'];
    usuario.nombre = json['nombre_envia'];

    tipoNotificacion.idTipoNotificacion = json['id_tipo_notificacion'];
    tipoNotificacion.nombre = json['nombre_tipo_notificacion'];

    Notificacion aux = Notificacion(
        json['id_notificacion'],
        json['titulo'],
        json['mensaje'],
        DateTime.parse(json['fecha']),
        json['leida'],
        tipoNotificacion,
        usuario);
    return aux;
  }

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

  static List<Notificacion> listaVistaPrevia(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<Notificacion>((json) => Notificacion.fromJsonVistaPrevia(json))
        .toList();
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "idNotificacion: $idNotificacion, ";
    retorno += "titulo: $titulo, ";
    retorno += "mensaje: $mensaje";
    retorno += "fecha: $fecha";
    retorno += "leida: $leida";
    retorno += "tipoNotificacion: $tipoNotificacion";
    retorno += "usuarioEnvia: $usuarioEnvia";
    return retorno;
  }

  String fechaFormateada() {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  String nombreUsuarioQueEnvia() {
    return "${usuarioEnvia.ci} - ${usuarioEnvia.nombre}";
  }

  void marcarNotificacionComoLeida() {
    _leida = true;
  }
}
