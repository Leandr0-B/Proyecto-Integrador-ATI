class Medicamento {
  //Atributos
  int _id_medicamento = 0;
  String _nombre = "";
  String _unidad = "";

  //Constructor
  Medicamento(this._nombre, this._unidad);

  Medicamento.empty();

  Medicamento.json(this._id_medicamento, this._nombre, this._unidad);

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento.json(json['id_medicamento'], json['nombre'], json['unidad']);
  }

  //Get Set
  int get id_medicamento => this._id_medicamento;

  set id_medicamento(int value) => this._id_medicamento = value;

  String get nombre => this._nombre;

  set nombre(String value) => this._nombre = value;

  String get unidad => this._unidad;

  void setUnidad(String unidad) {
    this._unidad = unidad;
  }

  //Funciones
  static List<Medicamento> fromJsonList(List<dynamic> jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<Medicamento>((json) => Medicamento.fromJson(json)).toList();
  }

  //Equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Medicamento && _id_medicamento == other.id_medicamento;
  }

  //ToString
  @override
  String toString() {
    return _nombre + " | Unidad: " + _unidad;
  }
}
