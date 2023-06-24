import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaSalidaMedica.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class VistaSalidaMedica extends StatefulWidget {
  @override
  State<VistaSalidaMedica> createState() => _VistaSalidaMedicaState();
}

class _VistaSalidaMedicaState extends State<VistaSalidaMedica> {
  final _formKey = GlobalKey<FormState>();
  ControllerVistaSalidaMedica? controller;
  Usuario? selectedResidente;

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaSalidaMedica(mostrarMensaje: mostrarMensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alta salida medica',
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
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Seleccione el residente:"),
                  ),
                  SizedBox(height: 16.0),
                  FutureBuilder<List<Usuario>?>(
                    future: listaResidentes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error al cargar los residentes');
                      } else {
                        final residentesList = snapshot.data;

                        if (residentesList != null &&
                            residentesList.isNotEmpty) {
                          return DropdownButtonFormField<Usuario>(
                            value: selectedResidente,
                            onChanged: (Usuario? newValue) {
                              setState(() {
                                selectedResidente = newValue;
                              });
                            },
                            items: residentesList.map((Usuario usuario) {
                              return DropdownMenuItem<Usuario>(
                                value: usuario,
                                child: Text(usuario.nombre ?? ""),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Residente',
                            ),
                          );
                        } else {
                          return Text('No hay residentes disponibles');
                        }
                      }
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }

  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<List<Usuario>?> listaResidentes() async {
    final residentes = await controller?.listaResidentes();
    return residentes ?? [];
  }
}
