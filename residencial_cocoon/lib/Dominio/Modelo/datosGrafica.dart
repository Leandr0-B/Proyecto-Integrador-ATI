class DatosGrafica {
  //Atributos
  double _valor = 0;
  DateTime _fecha = DateTime.now();

  //Constructor
  DatosGrafica.empty();
  DatosGrafica(this._valor, this._fecha);

  factory DatosGrafica.fromJson(Map<String, dynamic> json) {
    DatosGrafica datosAux = DatosGrafica(
      json['valor'],
      DateTime.parse(json['fecha']),
    );
    return datosAux;
  }

  //Get Set
  get valor => this._valor;
  set valor(value) => this._valor = value;

  get fecha => this._fecha;
  set fecha(value) => this._fecha = value;

  //Funciones
  static List<DatosGrafica> listaJson(List jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<DatosGrafica>((json) => DatosGrafica.fromJson(json)).toList();
  }
}
