import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class SalidaMedica {
  //Atributos
  int _id_salida_medica = 0;
  String _descripcion = "";
  DateTime _fecha_desde = DateTime(0);
  DateTime _fecha_hasta = DateTime(0);
  Geriatra _geriatra = Geriatra.empty();
  Residente _residente = Residente.empty();

  //Constructor
  SalidaMedica(this._descripcion, this._fecha_desde, this._fecha_hasta);

  factory SalidaMedica.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario geriatraAux = Usuario.empty();
    geriatraAux.ci = json['ci_geriatra'];
    geriatraAux.nombre = json['nombre_geriatra'];
    geriatraAux.apellido = json['apellido_geriatra'];

    Usuario residenteAux = Usuario.empty();
    residenteAux.ci = json['ci_residente'];
    residenteAux.nombre = json['nombre_residente'];
    residenteAux.apellido = json['apellido_residente'];

    SalidaMedica aux = SalidaMedica(
        json['descripcion'],
        DateTime.parse(json['fecha_desde']),
        DateTime.parse(json['fecha_hasta']));
    aux.agregarGeriatra(geriatraAux);
    aux.agregarResidente(residenteAux);
    aux._id_salida_medica = json['id_salida_medica'];

    return aux;
  }

  //Get Set
  int get idSalidaMedica => _id_salida_medica;
  set idSalidaMedica(int value) => _id_salida_medica = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  DateTime get fechaDesde => _fecha_desde;
  set fechaDesde(DateTime value) => _fecha_desde = value;

  DateTime get fechaHasta => _fecha_hasta;
  set fechaHasta(DateTime value) => _fecha_hasta = value;

  static List<SalidaMedica> listaVistaPrevia(List jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<SalidaMedica>((json) => SalidaMedica.fromJsonVistaPrevia(json))
        .toList();
  }

  void agregarGeriatra(Usuario geriatra) {
    _geriatra.usuario = geriatra;
  }

  void agregarResidente(Usuario residente) {
    _residente.usuario = residente;
  }

  String nombreResidente() {
    return _residente.nombreUsuario();
  }

  String apellidoResidente() {
    return _residente.apellidoUsuario();
  }

  String ciResidente() {
    return _residente.ciUsuario();
  }

  String nombreGeriatra() {
    return _geriatra.nombreUsuario();
  }

  String apellidoGeriatra() {
    return _geriatra.apellidoUsuario();
  }

  String ciGeriatra() {
    return _geriatra.ciUsuario();
  }

  //Funciones
}
