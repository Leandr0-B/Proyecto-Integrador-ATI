import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class ChequeoMedico {
  //Atributos
  int _id_chequeo = 0;
  String _descripcion = "";
  DateTime _fecha = DateTime(0);
  Geriatra _geriatra = Geriatra.empty();
  Residente _residente = Residente.empty();
  List<Control> _controles = [];

  //Constructor
  ChequeoMedico(
    this._id_chequeo,
    this._descripcion,
    this._fecha,
  );

  ChequeoMedico.empty();

  factory ChequeoMedico.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario geriatraAux = Usuario.empty();
    geriatraAux.ci = json['ci_geriatra'];
    geriatraAux.nombre = json['nombre_geriatra'];
    geriatraAux.apellido = json['apellido_geriatra'];

    Usuario residenteAux = Usuario.empty();
    residenteAux.ci = json['ci_residente'];
    residenteAux.nombre = json['nombre_residente'];
    residenteAux.apellido = json['apellido_residente'];

    ChequeoMedico aux = ChequeoMedico(json['id_chequeo'], json['descripcion'], DateTime.parse(json['fecha']));
    aux.agregarGeriatra(geriatraAux);
    aux.agregarResidente(residenteAux);

    List<Control> controlesList = [];
    //recuperar los controles del JSON y meterlos en el ChequeoMedico
    if (json.containsKey('controles')) {
      List<dynamic> controlesJson = json['controles'];
      if (controlesJson.isNotEmpty) {
        controlesList = controlesJson.map((controlJson) => Control.fromJsonPrescripcion(controlJson)).toList();
      }
    }
    aux._controles = controlesList;

    return aux;
  }

  //Get Set
  int get id_chequeo => _id_chequeo;

  get controles => _controles;

  set id_chequeo(int value) => _id_chequeo = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  DateTime get fecha => _fecha;
  set fecha(DateTime value) => _fecha = value;

  static List<ChequeoMedico> listaVistaPrevia(List jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<ChequeoMedico>((json) => ChequeoMedico.fromJsonVistaPrevia(json)).toList();
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

  String imprimirControlesMedicos() {
    String result = '\n';
    if (_controles.isNotEmpty) {
      for (var control in _controles) {
        result += '${control.nombre} ${control.unidad} ${control.valor_compuesto == 1 ? "${control.valor} - ${control.segundoValor}" : control.valor}\n';
      }
    }
    return result;
  }

  String imprimirFecha() {
    String dia = fecha.day.toString().padLeft(2, '0');
    String mes = fecha.month.toString().padLeft(2, '0');
    String anio = fecha.year.toString();
    String hora = fecha.hour.toString().padLeft(2, '0');
    String minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio - $hora:$minuto';
  }

  //Funciones
}
