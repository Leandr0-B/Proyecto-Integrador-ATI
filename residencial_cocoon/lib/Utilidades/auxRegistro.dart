import 'dart:ui';

class AuxRegistro {
  //Atributos
  Color _color = Color.fromARGB(0, 0, 0, 0);
  String _tipoIcono = "";

  //Constructores
  AuxRegistro.empty();
  AuxRegistro(this._color, this._tipoIcono);

  //Get Set
  Color get color => this._color;
  set color(Color value) => this._color = value;

  get tipoIcono => this._tipoIcono;
  set tipoIcono(value) => this._tipoIcono = value;
}
