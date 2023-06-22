import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAltaFuncionario.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';

class VistaAltaFuncionario extends StatefulWidget {
  @override
  _VistaAltaFuncionarioState createState() => _VistaAltaFuncionarioState();
}

class _VistaAltaFuncionarioState extends State<VistaAltaFuncionario> {
  final _formKey = GlobalKey<FormState>();
  String _ci = '';
  String _nombre = '';
  int _administrador = 0;
  List<int> selectedRoles = [];
  List<int> selectedSucursales = [];
  ControllerVistaAltaFuncionario? controller;
  final fieldCi = TextEditingController();
  final fieldNombre = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaAltaFuncionario(mostrarMensaje: mostrarMensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alta de Funcionario',
          style: TextStyle(color: Colors.black), // Cambia a tu color preferido.
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
                    labelText: 'Documento identificador',
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
                    labelText: 'Nombre',
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
                  child: Text("Seleccione los roles:"),
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
                  child: Text("Seleccione las sucursales:"),
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
                ElevatedButton(
                  child: Text("Crear funcionario"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      altaUsuarioFuncionario(_ci, _nombre, _administrador,
                          selectedRoles, selectedSucursales);
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
    bool? resultado = await controller?.altaUsuario(
        ci, nombre, administrador, selectedRoles, selectedSucursales);
    if (resultado == true) {
      _limpiarDatos();
    }
  }

  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _limpiarDatos() {
    setState(() {
      selectedRoles = [];
      selectedSucursales = [];
      fieldCi.clear();
      fieldNombre.clear();
    });
  }
}
