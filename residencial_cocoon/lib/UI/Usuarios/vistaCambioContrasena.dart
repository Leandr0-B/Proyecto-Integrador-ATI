import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaCambioContrasena.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaCambioContrasena.dart';

class VistaCambioContrasena extends StatefulWidget {
  @override
  State<VistaCambioContrasena> createState() => _VistaCambioContrasenaState();
}

class _VistaCambioContrasenaState extends State<VistaCambioContrasena>
    implements IvistaCambioContrasena {
  ControllerVistaCambioContrasena? controller;
  final _formKey = GlobalKey<FormState>();
  String _contrasenaActual = "";
  String _nuevaContrasena = "";
  String _nuevaContrasenaVerif = "";

  final fieldAct = TextEditingController();
  final fieldNuev = TextEditingController();
  final fieldVerif = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaCambioContrasena(
        mostrarMensaje: mostrarMensaje, limpiar: limpiar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cambio de contraseña',
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
                  maxLength: 100,
                  controller: fieldAct,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña actual',
                    hintText: 'Contraseña actual',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su contraseña actual.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _contrasenaActual = value!;
                  },
                ),
                TextFormField(
                  maxLength: 100,
                  controller: fieldNuev,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    hintText: 'Ingrese la nueva contraseña',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la nueva contraseña';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nuevaContrasena = value!;
                  },
                ),
                TextFormField(
                  maxLength: 100,
                  controller: fieldVerif,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Ingrese la contraseña otra vez',
                    hintText: 'Ingrese la nueva contraseña otra vez',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la nueva contraseña otra vez';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nuevaContrasenaVerif = value!;
                  },
                ),
                ElevatedButton(
                  child: Text("Cambiar clave"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      cambioClave(_contrasenaActual, _nuevaContrasena,
                          _nuevaContrasenaVerif);
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

  @override
  Future<void> cambioClave(
      String actual, String nueva, String verificacion) async {
    await controller?.cambioClave(actual, nueva, verificacion);
  }

  @override
  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
    ));
  }

  @override
  void limpiar() {
    fieldAct.clear();
    fieldNuev.clear();
    fieldVerif.clear();
  }
}
