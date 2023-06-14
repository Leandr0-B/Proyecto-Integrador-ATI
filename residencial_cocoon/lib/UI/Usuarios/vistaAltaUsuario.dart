import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class NuevoUsuarioPage extends StatefulWidget {
  @override
  _NuevoUsuarioPageState createState() => _NuevoUsuarioPageState();
}

class _NuevoUsuarioPageState extends State<NuevoUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  String _ci = '';
  String _nombre = '';
  int _administrador = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alta de nuevo usuario'),
        backgroundColor: Color.fromRGBO(225, 183, 72, 1),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
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
                CheckboxListTile(
                  title: Text("Administrador"),
                  value: _administrador == 1,
                  onChanged: (newValue) {
                    setState(() {
                      _administrador = newValue! ? 1 : 0;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Usuario nuevoUsuario = Usuario(
                        ci: _ci,
                        nombre: _nombre,
                        administrador: _administrador,
                        roles: [],
                        sucursales: [],
                      );
                      // Aquí puedes hacer algo con tu nuevoUsuario, como enviarlo a una API o agregarlo a una lista.
                      print(nuevoUsuario);
                    }
                  },
                  child: Text('Crear Usuario'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
