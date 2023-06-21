import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAltaResidente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

class VistaAltaResidente extends StatefulWidget {
  @override
  _VistaAltaResidenteState createState() => _VistaAltaResidenteState();
}

class _VistaAltaResidenteState extends State<VistaAltaResidente> {
  final _formKey = GlobalKey<FormState>();
  String _ci = '';
  String _nombre = '';
  String _ciFamiliar = '';
  String _nombreFamiliar = '';
  String _apellidoFamiliar = '';
  String _emailFamiliar = '';
  int _contactoPrimarioFamiliar = 0;
  bool _agregarContactoPrimario = false;
  ControllerVistaAltaResidente? controller;
  int? selectedSucursal;
  List<Familiar> _familiares = []; // Variable _familiares declarada aquí
  final fieldCi = TextEditingController();
  final fieldNombre = TextEditingController();
  final ciFamiliar = TextEditingController();
  final nombreFamiliar = TextEditingController();
  final apellidoFamiliar = TextEditingController();
  final emailFamiliar = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaAltaResidente(mostrarMensaje: mostrarMensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alta de Residente',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(195, 190, 190, 180),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  maxLength: 8,
                  controller: fieldCi,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese documento identificador',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese documento identificador';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _ci = value!;
                  },
                ),
                TextFormField(
                  maxLength: 100,
                  controller: fieldNombre,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese Nombre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese Nombre';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nombre = value!;
                  },
                ),
                SizedBox(height: 16.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione la sucursal:"),
                ),
                FutureBuilder<List<Sucursal>?>(
                  future: _getSucursales(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Sucursal>?> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: snapshot.data!.map((sucursal) {
                          final bool isSelected =
                              selectedSucursal == sucursal.idSucursal;

                          return RadioListTile<int>(
                            title: Text(sucursal.nombre),
                            value: sucursal.idSucursal,
                            groupValue: selectedSucursal,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedSucursal = newValue;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.only(left: 16, right: 0),
                          );
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Familiares:"),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ingrese CI del Familiar',
                  ),
                  controller: ciFamiliar,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese CI del Familiar';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _ciFamiliar = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ingrese Nombre del Familiar',
                  ),
                  controller: nombreFamiliar,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese Nombre del Familiar';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nombreFamiliar = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ingrese Apellido del Familiar',
                  ),
                  controller: apellidoFamiliar,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese Apellido del Familiar';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _apellidoFamiliar = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText:
                        'Ingrese Email del Familiar (ejemplo@ejemplo.ejem)',
                  ),
                  controller: emailFamiliar,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese Email del Familiar';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _emailFamiliar = value!;
                  },
                ),
                if (_shouldShowContactoPrimarioCheckbox())
                  CheckboxListTile(
                    title: Text("Contacto primario"),
                    value: _agregarContactoPrimario,
                    onChanged: (newValue) {
                      setState(() {
                        _agregarContactoPrimario = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ElevatedButton(
                  child: Text("Agregar familiar"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _agregarFamiliar(
                        _ciFamiliar,
                        _nombreFamiliar,
                        _apellidoFamiliar,
                        _emailFamiliar,
                        _contactoPrimarioFamiliar,
                      );
                    }
                  },
                ),
                if (_familiares != null &&
                    _familiares!
                        .isNotEmpty) // Verifica que _familiares no sea nulo antes de usarlo
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Lista de familiares:"),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _familiares?.length ?? 0,
                  itemBuilder: (context, index) {
                    final familiar = _familiares![index];
                    return ListTile(
                      title: Row(
                        children: [
                          Text(
                              '${familiar.nombre} ${familiar.apellido} ${familiar.ci}'),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () {
                              _eliminarFamiliar(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text("Crear usuario"),
                  onPressed: () {
                    _crearUsuario();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowContactoPrimarioCheckbox() {
    return _familiares == null ||
        _familiares!.isEmpty ||
        _familiares!.every((familiar) => familiar.contactoPrimario != 1);
  }

  void _agregarFamiliar(
    String _ciFamiliar,
    String _nombreFamiliar,
    String _apellidoFamiliar,
    String _emailFamiliar,
    int _contactoPrimarioFamiliar,
  ) {
    Familiar familiar = Familiar(
      ci: _ciFamiliar,
      nombre: _nombreFamiliar,
      apellido: _apellidoFamiliar,
      email: _emailFamiliar,
      contactoPrimario: _agregarContactoPrimario ? 1 : 0,
    );

    setState(() {
      bool resultado = controller!.controlAltaFamiliar(familiar, _familiares);
      if (resultado) {
        _familiares.add(familiar);
        if (_agregarContactoPrimario) {
          _agregarContactoPrimario = false;
        }
      }
    });
  }

  void _eliminarFamiliar(int index) {
    setState(() {
      _familiares.removeAt(index);
    });
  }

  Future<void> _crearUsuario() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool? resultado = await controller?.altaUsuario(
          _familiares, _ci, _nombre, selectedSucursal);
      if (resultado == true) {
        limpiarDatos();
        clearText();
      }
    }
  }

  Future<List<Sucursal>?> _getSucursales() async {
    return controller?.listaSucursales();
  }

  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void limpiarDatos() {
    setState(() {
      _ci = '';
      _nombre = '';
      _ciFamiliar = '';
      _nombreFamiliar = '';
      _apellidoFamiliar = '';
      _emailFamiliar = '';
      _contactoPrimarioFamiliar = 0;
      _agregarContactoPrimario = false;
      _familiares = [];
    });
  }

  void clearText() {
    fieldCi.clear();
    fieldNombre.clear();
    ciFamiliar.clear();
    nombreFamiliar.clear();
    apellidoFamiliar.clear();
    emailFamiliar.clear();
  }
}
