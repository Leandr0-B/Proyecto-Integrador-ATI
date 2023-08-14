class Control {
  //Atributos
  int _id_control = 0;
  String _nombre = '';
  String _unidad = '';
  double _valor = 0;
  double _segundoValor = 0;
  double _valor_referencia_minimo = 0;
  double _valor_referencia_maximo = 0;
  int _rango = 0;
  int _valor_compuesto = 0;
  double _maximo_valor_referencia_minimo = 0;
  double _maximo_valor_referencia_maximo = 0;

  //Contructor
  Control(this._id_control, this._nombre, this._unidad);

  Control.preview(this._id_control, this._nombre, this._unidad, this._valor);

  Control.empty();

  factory Control.fromJson(Map<String, dynamic> json) {
    return Control(json['id_control'], json['nombre'], json['unidad']);
  }

  Control.sinUnidad(this._id_control, this._nombre, this._valor);

  factory Control.fromJsonParaPreview(Map<String, dynamic> json) {
    return Control.preview(json['id_control'], json['nombre'], json['unidad'], json['valor']);
  }

  factory Control.fromJsonPrescripcion(Map<String, dynamic> json) {
    Control auxControl = Control.empty();

    auxControl.id_control = json['id_control'];
    auxControl.nombre = json['nombre'];
    auxControl.unidad = json['unidad'];
    auxControl.valor_referencia_minimo = json['valor_referencia_minimo'];
    auxControl.valor_referencia_maximo = json['valor_referencia_maximo'];
    auxControl.valor_compuesto = json['valor_compuesto'];
    if (auxControl.valor_compuesto == 1) {
      auxControl.maximo_valor_referencia_maximo = json['maximo_valor_referencia_maximo'];
      auxControl.maximo_valor_referencia_minimo = json['maximo_valor_referencia_minimo'];
    }
    return auxControl;
  }

  //Get Set
  int get id_control => this._id_control;
  set id_control(int value) => this._id_control = value;

  String get nombre => this._nombre;
  set nombre(String value) => this._nombre = value;

  double get valor => this._valor;
  set valor(double value) => this._valor = value;

  double get segundoValor => this._segundoValor;
  set segundoValor(double value) => this._segundoValor = value;

  String get unidad => this._unidad;
  set unidad(String value) => this._unidad = value;

  double get valor_referencia_minimo => this._valor_referencia_minimo;
  set valor_referencia_minimo(double value) => this._valor_referencia_minimo = value;

  get valor_referencia_maximo => this._valor_referencia_maximo;
  set valor_referencia_maximo(value) => this._valor_referencia_maximo = value;

  get rango => this._rango;
  set rango(value) => this._rango = value;

  get maximo_valor_referencia_minimo => this._maximo_valor_referencia_minimo;
  set maximo_valor_referencia_minimo(value) => this._maximo_valor_referencia_minimo = value;

  get maximo_valor_referencia_maximo => this._maximo_valor_referencia_maximo;
  set maximo_valor_referencia_maximo(value) => this._maximo_valor_referencia_maximo = value;

  int get valor_compuesto => this._valor_compuesto;
  set valor_compuesto(int value) => this._valor_compuesto = value;

  //Funciones
  static List<Control> fromJsonList(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<Control>((json) => Control.fromJson(json)).toList();
  }

  static List<Control> fromJsonListPrescripcion(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<Control>((json) => Control.fromJsonPrescripcion(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id_control': _id_control,
      'nombre': _nombre,
      'unidad': _unidad,
      'valor': _valor,
    };
  }

  static List<Map<String, dynamic>> listaParaApi(List<Control?> controles) {
    return controles.map((control) {
      if (control != null) {
        return {
          'id_control': control.id_control,
          'nombre': control.nombre,
        };
      }
      return <String, dynamic>{};
    }).toList();
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
    retorno += "unidad: $_unidad";
    retorno += "valor: $_valor";
    return retorno;
  }

  String toStringPrescripcion() {
    String retorno = "";
    retorno += "Nombre: $_nombre, ";
    retorno += "Unidad: $_unidad";

    return retorno;
  }
}
