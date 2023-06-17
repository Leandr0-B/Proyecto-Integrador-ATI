import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAltaUsuario.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

class NuevoUsuarioPage extends StatefulWidget {
  static String id = '/usuario/alta';
  @override
  _NuevoUsuarioPageState createState() => _NuevoUsuarioPageState();
}

class _NuevoUsuarioPageState extends State<NuevoUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  String _ci = '';
  String _nombre = '';
  String _nombreFamiliar = '';
  bool _esFuncionario = false;
  int _administrador = 0;
  List<int> selectedRoles = [];
  List<int> selectedSucursales = [];
  ControllerVistaAltaUsuario? controller;

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaAltaUsuario(mostrarMensaje: mostrarMensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alta de nuevo usuario'),
        backgroundColor: Color.fromRGBO(225, 183, 72, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CheckboxListTile(
                  title: Text("Funcionario"),
                  value: _esFuncionario,
                  onChanged: (newValue) {
                    setState(() {
                      _esFuncionario = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                TextFormField(
                  maxLength: 8,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese CI',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese CI';
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
                if (_esFuncionario) ...[
                  SizedBox(height: 16.0),
                  CheckboxListTile(
                    title: Text("Administrador"),
                    value: _administrador == 1,
                    onChanged: (newValue) {
                      setState(() {
                        _administrador = newValue! ? 1 : 0;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Seleccione los roles del usuario:"),
                  ),
                  FutureBuilder<List<Rol>?>(
                    future: _getRoles(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Rol>?> snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data!
                              .where((role) =>
                                  role.idRol !=
                                  3) // Esto excluirá el rol con id 3
                              .map((role) => CheckboxListTile(
                                    title: Text(role.descripcion),
                                    value: selectedRoles.contains(role.idRol),
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (newValue!) {
                                          selectedRoles.add(role.idRol);
                                        } else {
                                          selectedRoles.remove(role.idRol);
                                        }
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding:
                                        EdgeInsets.only(left: 16, right: 0),
                                  ))
                              .toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Seleccione las sucursales del usuario:"),
                  ),
                  FutureBuilder<List<Sucursal>?>(
                    future: _getSucursales(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Sucursal>?> snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data!
                              .map((sucursal) => CheckboxListTile(
                                    title: Text(sucursal.nombre),
                                    value: selectedSucursales
                                        .contains(sucursal.idSucursal),
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (newValue!) {
                                          selectedSucursales
                                              .add(sucursal.idSucursal);
                                        } else {
                                          selectedSucursales
                                              .remove(sucursal.idSucursal);
                                        }
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding:
                                        EdgeInsets.only(left: 16, right: 0),
                                  ))
                              .toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
                if (!_esFuncionario) ...[
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
                ],
                ElevatedButton(
                  child: Text("Crear usuario"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (_esFuncionario) {
                        altaUsuarioFuncionario(_ci, _nombre, _administrador,
                            selectedRoles, selectedSucursales);
                      } else {
                        //Alta no funcionarios
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Rol>?> _getRoles() async {
    return controller?.listaRoles();
  }

  Future<List<Sucursal>?> _getSucursales() async {
    return controller?.listaSucursales();
  }

  Future<void> altaUsuarioFuncionario(String ci, String nombre,
      int administrador, List<int> roles, List<int> sucursales) async {
    await controller?.altaUsuario(
        ci, nombre, administrador, selectedRoles, selectedSucursales);
  }

  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
