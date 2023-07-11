import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAltaMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/Medicamentos/iVistaAltaMedicamento.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaAltaMedicamento extends StatefulWidget {
  @override
  State<VistaAltaMedicamento> createState() => _VistaAltaMedicamentoState();
}

class _VistaAltaMedicamentoState extends State<VistaAltaMedicamento>
    implements IvistaAltaMedicamento {
  ControllerVistaAltaMedicamento controller =
      ControllerVistaAltaMedicamento.empty();
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  bool residentesVisible = false;
  String _nombreMedicamento = "";
  String? _selectedUnidad;
  final _formKey = GlobalKey<FormState>();
  final fieldNombre = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaAltaMedicamento(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Medicamento',
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
                Column(
                  children: [
                    SizedBox(height: 16.0),
                    TextFormField(
                      maxLength: 100,
                      controller: fieldNombre,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Medicamento',
                        hintText: 'Ingrese Nombre',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del medicamento';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _nombreMedicamento = value!;
                      },
                    ),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Seleccione la unidad:"),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButton<String>(
                        value: _selectedUnidad,
                        hint: const Text('Seleccione una opción'),
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'ml',
                            child: const Text('ml'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'c/u',
                            child: const Text('c/u'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'pastillas',
                            child: const Text('pastillas'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedUnidad = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  child: Text("Alta Medicamento"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      altaMedicamento();
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
  Future<void> altaMedicamento() async {
    await controller.altaMedicamento(_nombreMedicamento, _selectedUnidad);
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    setState(() {
      fieldNombre.clear();
      _selectedUnidad = null;
    });
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
}
