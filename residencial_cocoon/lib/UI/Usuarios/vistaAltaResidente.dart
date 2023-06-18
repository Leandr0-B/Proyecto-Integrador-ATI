import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAltaResidente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';

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
  bool _showContactoPrimarioCheckbox = true;
  ControllerVistaAltaResidente? controller;
  List<Familiar> _familiares = []; // Variable _familiares declarada aquí

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
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Familiares:"),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ingrese CI del Familiar',
                  ),
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
                    hintText: 'Ingrese Email del Familiar',
                  ),
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
                    value: _contactoPrimarioFamiliar == 1,
                    onChanged: (newValue) {
                      setState(() {
                        _contactoPrimarioFamiliar = newValue! ? 1 : 0;
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
                          Text('${familiar.nombre} ${familiar.apellido}'),
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
      contactoPrimario: _contactoPrimarioFamiliar,
    );

    setState(() {
      bool resultado = controller!.controlAlta(familiar, _familiares);
      if (resultado) {
        _familiares.add(familiar);
      }
    });
  }

  void _eliminarFamiliar(int index) {
    setState(() {
      _familiares.removeAt(index);
    });
  }

  void _crearUsuario() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Aquí puedes realizar acciones adicionales con los datos ingresados, como crear el usuario o realizar acciones personalizadas.
      // Por ejemplo, puedes imprimir los datos del usuario y sus familiares:
      print('Usuario:');
      print('CI: $_ci');
      print('Nombre: $_nombre');
      print('Familiares:');
      if (_familiares != null && _familiares!.isNotEmpty) {
        for (final familiar in _familiares!) {
          print('${familiar.nombre} ${familiar.apellido}');
        }
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
