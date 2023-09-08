import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaVisitaMedicaExterna.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisitaMedicaExterna.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VistaVisitaMedicaExterna extends StatefulWidget {
  @override
  State<VistaVisitaMedicaExterna> createState() => _VistaVisitaMedicaExternaState();
}

class _VistaVisitaMedicaExternaState extends State<VistaVisitaMedicaExterna> implements IvistaVisitaMedicaExterna {
  final _formKey = GlobalKey<FormState>();
  ControllerVistaVisitaMedicaExterna controller = ControllerVistaVisitaMedicaExterna.empty();
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  bool residentesVisible = false;
  String descripcion = '';
  DateTime? fecha;
  final fieldDescripcion = TextEditingController();

  //Speech
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = true;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    controller = ControllerVistaVisitaMedicaExterna(this);
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          descripcion = result.recognizedWords;
          fieldDescripcion.text = descripcion; // Rellenar el campo de descripción con el texto reconocido
        });
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Visita Médica Externa',
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
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione la sucursal:"),
                ),
                FutureBuilder<List<Sucursal>?>(
                  future: listaSucursales(),
                  builder: (BuildContext context, AsyncSnapshot<List<Sucursal>?> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: snapshot.data!.map((sucursal) {
                          return RadioListTile<Sucursal>(
                            title: Text(sucursal.nombre),
                            value: sucursal,
                            groupValue: selectedSucursal,
                            onChanged: (Sucursal? newValue) {
                              setState(() {
                                selectedSucursal = newValue;
                                selectedResidente = null;
                                residentesVisible = true;
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
                Column(
                  children: [
                    if (residentesVisible) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Seleccione un residente:"),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FutureBuilder<List<Usuario>?>(
                          future: listaResidentes(),
                          builder: (BuildContext context, AsyncSnapshot<List<Usuario>?> snapshot) {
                            if (snapshot.hasData) {
                              List<Usuario> residentes = snapshot.data!;
                              return DropdownButton<Usuario>(
                                value: selectedResidente,
                                items: [
                                  DropdownMenuItem<Usuario>(
                                    value: null,
                                    child: Text("Seleccione un residente"),
                                  ),
                                  ...residentes.map((residente) {
                                    return DropdownMenuItem<Usuario>(
                                      value: residente,
                                      child: Text(residente.ci + ' - ' + residente.nombre + " " + residente.apellido),
                                    );
                                  }),
                                ],
                                onChanged: (Usuario? newValue) {
                                  setState(() {
                                    selectedResidente = newValue;
                                  });
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Ingrese una descripción:"),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      bool isDesktop = constraints.maxWidth >= 600;

                      return TextFormField(
                        controller: fieldDescripcion,
                        maxLines: null,
                        onChanged: (value) {
                          descripcion = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una descripción.';
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Descripción',
                          suffixIcon: isDesktop
                              ? IconButton(
                                  onPressed: _toggleListening,
                                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                                )
                              : null,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          border: InputBorder.none,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione la fecha:"),
                ),
                InkWell(
                  onTap: () => _selectFecha(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Fecha',
                    ),
                    child: Text(
                      fecha != null ? DateFormat('dd/MM/yyyy').format(fecha!) : 'Seleccione una fecha',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      altaVisitaMedicaExt();
                    }
                  },
                  child: Text('Ingresar visita'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFecha(BuildContext context) async {
    DateTime? picked = await Utilidades.selectFechaSinTope(context, fecha);
    if (picked != null && picked != fecha) {
      setState(() {
        fecha = picked;
      });
    }
  }

  @override
  Future<List<Sucursal>?> listaSucursales() async {
    return controller.listaSucursales();
  }

  @override
  Future<List<Usuario>?> listaResidentes() async {
    return await controller.listaResidentes(selectedSucursal);
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
  Future<void> altaVisitaMedicaExt() async {
    await controller.altaVisitaMedicaExt(selectedResidente, descripcion, fecha, selectedSucursal);
  }

  @override
  void limpiar() {
    setState(() {
      fieldDescripcion.clear();
      fecha = null;
      selectedResidente = null;
      selectedSucursal = null;
      residentesVisible = false;
    });
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }
}
