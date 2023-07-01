class Control {
  //Atributos
  int _id_control = 0;
  String _nombre = '';
  String _uniadad = '';
  String _valor = '';

  //Contructor
  Control(this._id_control, this._nombre, this._uniadad);

  factory Control.fromJson(Map<String, dynamic> json) {
    return Control(json['id_control'], json['nombre'], json['unidad']);
  }

  Control.sinUnidad(this._id_control, this._nombre, this._valor);

  //Get Set
  int get id_control => this._id_control;
  set id_control(int value) => this._id_control = value;

  String get nombre => this._nombre;
  set nombre(String value) => this._nombre = value;

  String get valor => this._valor;

  set valor(String value) => this._valor = value;

  //Funciones
  static List<Control> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<Control>((json) => Control.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id_control': _id_control,
      'nombre': _nombre,
      'unidad': _uniadad,
      'valor': _valor,
    };
  }

  //Equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Control && _id_control == other._id_control;
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "idControl: $_id_control, ";
    retorno += "nombre: $_nombre, ";
    retorno += "unidad: $_uniadad";
    retorno += "valor: $_valor";
    return retorno;
  }
}
