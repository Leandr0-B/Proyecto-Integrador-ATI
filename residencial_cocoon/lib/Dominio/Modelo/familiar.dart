class Familiar {
  //Atributos
  String _ci;
  String _nombre;
  String _apellido;
  String _email;
  int _contactoPrimario;

  //Constructorres
  Familiar({
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    required int contactoPrimario,
  })  : _ci = ci,
        _nombre = nombre,
        _apellido = apellido,
        _email = email,
        _contactoPrimario = contactoPrimario;

  factory Familiar.fromJson(Map<String, dynamic> json) {
    // Crear y retornar un nuevo objeto Usuario
    return Familiar(
      ci: json['ci'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      contactoPrimario: json['contacto_primario'],
    );
  }

  //Funciones
  Map<String, dynamic> toJson() {
    return {
      'ci': _ci,
      'nombre': _nombre,
      'apellido': _apellido,
      'email': _email,
      'contactoPrimario': _contactoPrimario,
    };
  }

  //ToString
  @override
  String toString() {
    return toJson().toString();
  }

  String toStringMostrar() {
    String primario = "No es primario";
    if (this._contactoPrimario == 1) {
      primario = "Es contacto primario";
    }

    return this._nombre +
        " " +
        this._apellido +
        " " +
        primario +
        " " +
        this._email;
  }
}
