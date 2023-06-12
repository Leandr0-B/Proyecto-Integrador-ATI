class Sucursal {
  int _idSucursal;
  String _nombre;
  String _direccion;

  Sucursal(
      {required int idSucursal,
      required String nombre,
      required String direccion})
      : _idSucursal = idSucursal,
        _nombre = nombre,
        _direccion = direccion;

  int get idSucursal => _idSucursal;
  set idSucursal(int value) => _idSucursal = value;

  String get nombre => _nombre;
  set nombre(String value) => _nombre = value;

  String get direccion => _direccion;
  set direccion(String value) => _direccion = value;

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      idSucursal: json['id_sucursal'],
      nombre: json['nombre'],
      direccion: json['direccion'],
    );
  }

  @override
  String toString() {
    return 'Sucursal(idSucursal: $_idSucursal, nombre: $_nombre, direccion: $_direccion)';
  }
}
