import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class VisitaMedicaExterna {
  //Atributos
  int _id_visita_medica = 0;
  String _descripcion = "";
  DateTime _fecha = DateTime(0);
  Geriatra _geriatra = Geriatra.empty();
  Residente _residente = Residente.empty();

  //Constructor
  VisitaMedicaExterna(this._id_visita_medica, this._descripcion, this._fecha);

  factory VisitaMedicaExterna.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario geriatraAux = Usuario.empty();
    geriatraAux.ci = json['ci_geriatra'];
    geriatraAux.nombre = json['nombre_geriatra'];
    geriatraAux.apellido = json['apellido_geriatra'];

    Usuario residenteAux = Usuario.empty();
    residenteAux.ci = json['ci_residente'];
    residenteAux.nombre = json['nombre_residente'];
    residenteAux.apellido = json['apellido_residente'];

    VisitaMedicaExterna aux = VisitaMedicaExterna(json['id_visita_externa'],
        json['descripcion'], DateTime.parse(json['fecha']));
    aux.agregarGeriatra(geriatraAux);
    aux.agregarResidente(residenteAux);

    return aux;
  }

  //Get Set
  int get idVisitaMedica => _id_visita_medica;
  set idVisitaMedica(int value) => _id_visita_medica = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  DateTime get fecha => _fecha;
  set fecha(DateTime value) => _fecha = value;

  static List<VisitaMedicaExterna> listaVistaPrevia(List jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<VisitaMedicaExterna>(
            (json) => VisitaMedicaExterna.fromJsonVistaPrevia(json))
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
    return _residente.apellidoUsuario();
  }

  String ciGeriatra() {
    return _geriatra.ciUsuario();
  }

  //Funciones
}
