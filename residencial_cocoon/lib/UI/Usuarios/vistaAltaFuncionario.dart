import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAltaFuncionario.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaAltaFuncionario.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaAltaFuncionario extends StatefulWidget {
  @override
  _VistaAltaFuncionarioState createState() => _VistaAltaFuncionarioState();
}

class _VistaAltaFuncionarioState extends State<VistaAltaFuncionario> implements IvistaAltaFuncionario {
  final _formKey = GlobalKey<FormState>();
  String _ci = '';
  String _nombre = '';
  String _apellido = '';
  String _telefono = '';
  int _administrador = 0;
  String _email = '';
  DateTime? _fechaNacimiento;
  List<int> selectedRoles = [];
  List<int> selectedSucursales = [];
  ControllerVistaAltaFuncionario controller = ControllerVistaAltaFuncionario.empty();
  final fieldCi = TextEditingController();
  final fieldNombre = TextEditingController();
  final fieldApellido = TextEditingController();
  final fieldTelefono = TextEditingController();
  final fieldEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaAltaFuncionario(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Funcionario',
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
                    if (num.tryParse(value) == null) {
                      return 'Solo puede ingresar valores nueméricos.';
                    } else if (num.tryParse(value)! <= 0) {
                      return 'Ingresar el documento identificador sin puntos ni guiones.';
                    }
                    if (value.contains(RegExp(r'[,.]'))) {
                      return 'Ingresar el documento identificador sin puntos ni guiones.';
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
                      return 'Por favor ingrese nombre';
                    }
                    // Expresión regular que permite solo letras (mayúsculas y minúsculas).
                    final RegExp regex = RegExp(r'^[a-zA-Z ]+$');
                    if (!regex.hasMatch(value)) {
                      return 'Por favor ingrese solo letras';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nombre = value!;
                  },
                ),
                TextFormField(
                  maxLength: 100,
                  controller: fieldApellido,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    hintText: 'Ingrese Apellido',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese apellido';
                    }
                    // Expresión regular que permite solo letras (mayúsculas y minúsculas).
                    final RegExp regex = RegExp(r'^[a-zA-Z ]+$');
                    if (!regex.hasMatch(value)) {
                      return 'Por favor ingrese solo letras';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _apellido = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Telefono ',
                    hintText: 'Ingrese telefono',
                  ),
                  maxLength: 100,
                  controller: fieldTelefono,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el telefono.';
                    }
                    if (num.tryParse(value) == null) {
                      return 'Solo puede ingresar valores nueméricos.';
                    } else if (num.tryParse(value)! <= 0) {
                      return 'No es un número de telefono válido.';
                    }
                    if (value.contains(RegExp(r'[,.]'))) {
                      return 'Ingresar telefono sin puntos ni guiones.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _telefono = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Ingrese Email (ejemplo@ejemplo.ejem)',
                  ),
                  maxLength: 100,
                  controller: fieldEmail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese email';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione la fecha de nacimiento:"),
                ),
                InkWell(
                  onTap: () => _selectFechaNacimiento(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Fecha nacimiento',
                    ),
                    child: Text(
                      _fechaNacimiento != null ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!) : 'Seleccione una fecha',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                CheckboxListTile(
                  title: Text("Administrador"),
                  value: _administrador == 1,
                  onChanged: (newValue) {
                    setState(() {
                      _administrador = newValue! ? 1 : 0;
                      selectedRoles = [];
                      selectedSucursales = [];
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_administrador == 0)
                  Column(
                    children: [
                      SizedBox(height: 16.0),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Seleccione los roles:"),
                      ),
                      FutureBuilder<List<Rol>?>(
                        future: getRoles(),
                        builder: (BuildContext context, AsyncSnapshot<List<Rol>?> snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: snapshot.data!
                                  .where((role) => role.idRol != 3) // Esto excluirá el rol con id 3
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
                                        controlAffinity: ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.only(left: 16, right: 0),
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
                        future: getSucursales(),
                        builder: (BuildContext context, AsyncSnapshot<List<Sucursal>?> snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: snapshot.data!
                                  .map((sucursal) => CheckboxListTile(
                                        title: Text(sucursal.nombre),
                                        value: selectedSucursales.contains(sucursal.idSucursal),
                                        onChanged: (newValue) {
                                          setState(() {
                                            if (newValue!) {
                                              selectedSucursales.add(sucursal.idSucursal);
                                            } else {
                                              selectedSucursales.remove(sucursal.idSucursal);
                                            }
                                          });
                                        },
                                        controlAffinity: ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.only(left: 16, right: 0),
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
                  ),
                ElevatedButton(
                  child: Text("Crear funcionario"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      altaUsuarioFuncionario(_ci, _nombre, _administrador, selectedRoles, selectedSucursales, _apellido, _telefono, _email);
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

  Future<void> _selectFechaNacimiento(BuildContext context) async {
    DateTime? picked = await Utilidades.selectFechaNacimiento(context, _fechaNacimiento);
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  @override
  Future<List<Rol>?> getRoles() async {
    return controller.listaRoles();
  }

  @override
  Future<List<Sucursal>?> getSucursales() async {
    return controller.listaSucursales();
  }

  @override
  Future<void> altaUsuarioFuncionario(String ci, String nombre, int administrador, List<int> roles, List<int> sucursales, String apellido, String telefono, String email) async {
    await controller.altaUsuario(ci, nombre, administrador, selectedRoles, selectedSucursales, apellido, telefono, email, _fechaNacimiento);
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
      selectedRoles = [];
      selectedSucursales = [];
      fieldCi.clear();
      fieldNombre.clear();
      fieldApellido.clear();
      fieldTelefono.clear();
      fieldEmail.clear();
      _fechaNacimiento = null;
    });
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }
}
