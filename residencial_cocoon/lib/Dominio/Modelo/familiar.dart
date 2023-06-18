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

  //Get Set
  int get contactoPrimario => this._contactoPrimario;

  set contactoPrimario(int value) => this._contactoPrimario = value;

  String get nombre => this._nombre;

  set nombre(String value) => this._nombre = value;
  String get apellido => this._apellido;

  set apellido(String value) => this._apellido = value;

  //Funciones
  Map<String, dynamic> toJson() {
    return {
      'ci': _ci,
      'nombre': _nombre,
      'apellido': _apellido,
      'email': _email,
      'contacto_primario': _contactoPrimario,
    };
  }

  //ToString
  @override
  String toString() {
    return toJson().toString();
  }

  String toStringMostrar() {
    String primario = "no";
    if (this._contactoPrimario == 1) {
      primario = "si";
    }

    return this._nombre +
        " " +
        this._apellido +
        " " +
        "Es contacto primario: " +
        primario +
        " " +
        this._email;
  }

  // Equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Familiar && other._ci == _ci;
  }

  @override
  int get hashCode => _ci.hashCode;
}
