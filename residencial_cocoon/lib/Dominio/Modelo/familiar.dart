class Familiar {
  //Atributos
  String _ci = "";
  String _nombre = "";
  String _apellido = "";
  String _email = "";
  String _telefono = "";
  int _contactoPrimario = 0;

  //Constructorres
  Familiar(
    this._ci,
    this._nombre,
    this._apellido,
    this._email,
    this._contactoPrimario,
    this._telefono,
  );

  Familiar.lista(
    this._ci,
    this._nombre,
    this._apellido,
    this._email,
    this._contactoPrimario,
  );

  factory Familiar.fromJson(Map<String, dynamic> json) {
    // Crear y retornar un nuevo objeto Usuario
    return Familiar(
      json['ci'],
      json['nombre'],
      json['apellido'],
      json['email'],
      json['contacto_primario'] ?? 0,
      json['telefono'],
    );
  }

  factory Familiar.fromJsonList(Map<String, dynamic> json) {
    // Crear y retornar un nuevo objeto Usuario
    return Familiar.lista(
      json['ci_familiar'],
      json['nombre'],
      json['apellido'],
      json['email'],
      json['contacto_primario'] ?? 0,
    );
  }

  //Get Set
  int get contactoPrimario => this._contactoPrimario;

  set contactoPrimario(int value) => this._contactoPrimario = value;

  String get nombre => this._nombre;

  set nombre(String value) => this._nombre = value;
  String get apellido => this._apellido;

  set apellido(String value) => this._apellido = value;

  String get ci => this._ci;

  set ci(String value) => this._ci = value;

  String get email => this._email;

  set email(String value) => this._email = value;

  String get telefono => this._telefono;

  set telefono(String value) => this._telefono = value;

  //Funciones
  Map<String, dynamic> toJson() {
    return {
      "ci": _ci,
      "nombre": _nombre,
      "apellido": _apellido,
      "email": _email,
      "contacto_primario": _contactoPrimario,
      "telefono": _telefono,
    };
  }

  bool esEmailValido() {
    // Expresión regular para verificar el formato del email
    const pattern = r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$';
    final regex = RegExp(pattern);

    return regex.hasMatch(this._email);
  }

  void capitalizeAll() {
    _nombre = _capitalize(_nombre);
    _apellido = _capitalize(_apellido);
  }

  String _capitalize(String text) {
    List<String> words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        words[i] = word[0].toUpperCase() + word.substring(1);
      }
    }
    return words.join(' ');
  }

  static List<Familiar> listaVistaPrevia(List jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<Familiar>((json) => Familiar.fromJsonList(json)).toList();
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "ci: $_ci, ";
    retorno += "nombre: $_nombre, ";
    retorno += "apellido: $_apellido, ";
    retorno += "email: $_email, ";
    retorno += "contactoPrimario: $_contactoPrimario, ";
    return retorno;
  }

  String toStringMostrar() {
    String primario = "no";
    if (_contactoPrimario == 1) {
      primario = "si";
    }

    return "${this._nombre} - ${this._apellido} - Primario: $primario  - ${this._email}";
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
