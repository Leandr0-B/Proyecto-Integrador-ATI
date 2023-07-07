import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAltaResidente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaAltaResidente.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaAltaResidente extends StatefulWidget {
  @override
  _VistaAltaResidenteState createState() => _VistaAltaResidenteState();
}

class _VistaAltaResidenteState extends State<VistaAltaResidente>
    implements IvistaAltaResidente {
  final _formKey = GlobalKey<FormState>();
  final _familiarKey = GlobalKey<FormState>();
  String _ci = '';
  String _nombre = '';
  String _ciFamiliar = '';
  String _nombreFamiliar = '';
  String _apellidoFamiliar = '';
  String _emailFamiliar = '';
  int _contactoPrimarioFamiliar = 0;
  bool _agregarContactoPrimario = false;
  ControllerVistaAltaResidente controller =
      ControllerVistaAltaResidente.empty();
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
    controller = ControllerVistaAltaResidente(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Residente',
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
                  maxLength: 30,
                  controller: fieldCi,
                  decoration: const InputDecoration(
                    labelText: 'Documento identificador residente',
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
                    labelText: 'Nombre residente',
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
                  future: getSucursales(),
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
                Form(
                  key: _familiarKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Documento del familiar',
                          hintText: 'Ingrese CI del Familiar',
                        ),
                        maxLength: 30,
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
                          labelText: 'Nombre del familiar',
                          hintText: 'Ingrese Nombre del Familiar',
                        ),
                        maxLength: 100,
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
                          labelText: 'Apellido del familiar',
                          hintText: 'Ingrese Apellido del Familiar',
                        ),
                        maxLength: 100,
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
                          labelText: 'Email del familiar',
                          hintText:
                              'Ingrese Email del Familiar (ejemplo@ejemplo.ejem)',
                        ),
                        maxLength: 100,
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
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text("Agregar familiar"),
                  onPressed: () {
                    if (_familiarKey.currentState!.validate()) {
                      _familiarKey.currentState!.save();
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
                          if (familiar.contactoPrimario == 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Primario',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          _eliminarFamiliar(index);
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text("Crear usuario"),
                  onPressed: () {
                    crearUsuario();
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
    return controller.mostrarPrimario(_familiares);
  }

  void _agregarFamiliar(
    String _ciFamiliar,
    String _nombreFamiliar,
    String _apellidoFamiliar,
    String _emailFamiliar,
    int _contactoPrimarioFamiliar,
  ) {
    Familiar familiar = Familiar(
      _ciFamiliar,
      _nombreFamiliar,
      _apellidoFamiliar,
      _emailFamiliar,
      _agregarContactoPrimario ? 1 : 0,
    );

    setState(() {
      bool resultado = controller.controlAltaFamiliar(familiar, _familiares);
      if (resultado) {
        if (_agregarContactoPrimario) {
          _agregarContactoPrimario = false;
        }
      }
    });
  }

  void _eliminarFamiliar(int index) {
    setState(() {
      controller.eliminarFamiliar(_familiares, index);
    });
  }

  @override
  Future<void> crearUsuario() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await controller.altaUsuario(_familiares, _ci, _nombre, selectedSucursal);
    }
  }

  @override
  Future<List<Sucursal>?> getSucursales() async {
    return controller.listaSucursales();
  }

  @override
  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.green,
    ));
  }

  @override
  void mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.red,
    ));
  }

  @override
  void limpiarDatos() {
    setState(() {
      fieldCi.clear();
      fieldNombre.clear();
      ciFamiliar.clear();
      nombreFamiliar.clear();
      apellidoFamiliar.clear();
      emailFamiliar.clear();
      _contactoPrimarioFamiliar = 0;
      _agregarContactoPrimario = false;
      _familiares = [];
    });
  }

  @override
  void limpiarDatosFamiliar() {
    ciFamiliar.clear();
    nombreFamiliar.clear();
    apellidoFamiliar.clear();
    emailFamiliar.clear();
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }
}
