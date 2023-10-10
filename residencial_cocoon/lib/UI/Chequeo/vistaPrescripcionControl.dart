import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaPrescripcionControl.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Chequeo/iVistaPrescripcionControl.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VistaPrescripcionControl extends StatefulWidget {
  @override
  State<VistaPrescripcionControl> createState() => _VistaPrescripcionControlState();
}

class _VistaPrescripcionControlState extends State<VistaPrescripcionControl> implements IvistaPrescripcionControl {
  ControllerVistaPrescripcionControl _controller = ControllerVistaPrescripcionControl.empty();
  final _formKey = GlobalKey<FormState>();
  Usuario? _selectedResidente;
  Sucursal? _selectedSucursal;
  Future<List<Control>?> _controles = Future.value([]);
  List<Control?> _selectedControles = [];

  //Prescripcion
  int _prescripcionCronica = 0;
  int _duracion = 0;
  String _descripcion = "";
  int _frecuencia = 0;
  TimeOfDay? _hora_comienzo;
  final _fieldDescripcion = TextEditingController();
  final _fieldFrecuencia = TextEditingController();
  final _fieldDuracion = TextEditingController();

  //Speech
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = true;

  //Control alta
  final _formKeyControl = GlobalKey<FormState>();
  String _nombreControl = "";
  String _unidadControl = "";
  int _compuestoControl = 0;
  double _valorReferenciaMinimo = 0;
  double _valorReferenciaMaximo = 0;
  double _maximoValorReferenciaMaximo = 0;
  double _maximoValorReferenciaMinimo = 0;
  final _nombreControlController = TextEditingController();
  final _unidadControlController = TextEditingController();
  final _valorReferenciaMinimoController = TextEditingController();
  final _valorReferenciaMaximoController = TextEditingController();
  final _maximoValorReferenciaMaximoController = TextEditingController();
  final _maximoValorReferenciaMinimoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _controller = ControllerVistaPrescripcionControl(this);
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
          _descripcion = result.recognizedWords;
          _fieldDescripcion.text = _descripcion; // Rellenar el campo de descripción con el texto reconocido
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
        title: const Text(
          'Registrar Prescripcion de Control',
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
                            groupValue: _selectedSucursal,
                            onChanged: (Sucursal? newValue) {
                              setState(() {
                                _selectedSucursal = newValue;
                                _selectedResidente = null;
                                _selectedControles.clear();
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
                    if (_selectedSucursal != null) ...[
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
                                value: _selectedResidente,
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
                                    _selectedResidente = newValue;
                                    _selectedControles.clear();
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
                      if (_selectedResidente != null) ...[
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _selectedControles.clear();
                            obtenerControles();
                            _mostrarPopUp();
                          },
                          child: Text('Seleccionar control'),
                        ),
                        if (_selectedControles.isNotEmpty) ...[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text("Lista de controles"),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _selectedControles.length ?? 0,
                            itemBuilder: (context, index) {
                              final control = _selectedControles![index];
                              return ListTile(
                                title: Row(
                                  children: [
                                    Text('${control?.nombre} ${control?.unidad}'),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle),
                                      onPressed: () {
                                        setState(() {
                                          _selectedControles.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Ingrese una descripción de la prescripcion:"),
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
                                  controller: _fieldDescripcion,
                                  maxLines: null,
                                  onChanged: (value) {
                                    _descripcion = value;
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
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Ingrese la frecuencia en horas:',
                              hintText: 'Frecuencia de control en horas',
                            ),
                            maxLength: 100,
                            controller: _fieldFrecuencia,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese la frecuencia del control.';
                              }
                              if (num.tryParse(value) == null) {
                                return 'Solo puede ingresar valores numéricos.';
                              }
                              if (num.tryParse(value)! <= 0) {
                                return 'Solo puede ingresar valores positivos.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _frecuencia = int.parse(value!);
                            },
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Seleccione la hora de comienzo:"),
                          ),
                          InkWell(
                            onTap: () => _selectHora(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                hintText: 'Hora',
                              ),
                              child: Text(
                                _hora_comienzo != null ? _hora_comienzo!.format(context) : 'Seleccione una hora',
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          CheckboxListTile(
                            title: Text("Prescripción Crónica"),
                            value: _prescripcionCronica == 1,
                            onChanged: (newValue) {
                              setState(() {
                                _prescripcionCronica = newValue! ? 1 : 0;
                                _fieldDuracion.clear();
                                _duracion = 0;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_prescripcionCronica == 0)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese la duracion en días:',
                                hintText: 'Duración de prescripción en días',
                              ),
                              maxLength: 100,
                              controller: _fieldDuracion,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese la duración de la prescripción.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _duracion = int.parse(value!);
                              },
                            ),
                        ]
                      ],
                    ],
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      altaPrescripcion();
                    }
                  },
                  child: Text('Ingresar prescripción'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectHora(BuildContext context) async {
    TimeOfDay? picked = await Utilidades.selectHora(context, _hora_comienzo);

    if (picked != null && picked != _hora_comienzo) {
      setState(() {
        _hora_comienzo = picked;
      });
    }
  }

  @override
  Future<void> altaPrescripcion() async {
    _controller.altaPrescripcion(_selectedControles, _selectedResidente, _selectedSucursal, _descripcion, _frecuencia, _prescripcionCronica, _hora_comienzo, _duracion);
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    setState(() {
      _fieldDescripcion.clear();
      _fieldFrecuencia.clear();
      _fieldDuracion.clear();
      _prescripcionCronica = 0;
      _hora_comienzo = null;
      _selectedControles.clear();
      _selectedResidente = null;
      _selectedSucursal = null;
    });
  }

  @override
  void limpiarControl() {
    setState(() {
      _nombreControlController.clear();
      _unidadControlController.clear();
      _valorReferenciaMinimoController.clear();
      _valorReferenciaMaximoController.clear();
      _maximoValorReferenciaMaximoController.clear();
      _maximoValorReferenciaMinimoController.clear();
      _compuestoControl = 0;
    });
  }

  @override
  Future<List<Usuario>?> listaResidentes() async {
    return await _controller.listaResidentes(_selectedSucursal);
  }

  @override
  Future<List<Sucursal>?> listaSucursales() async {
    return await _controller.listaSucursales();
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
  Future<void> obtenerControles() async {
    _controles = _controller.listaControles();
    setState(() {});
  }

  Future<void> _registrarControl() async {
    await _controller.registrarControl(
        _nombreControl, _unidadControl, _compuestoControl, _valorReferenciaMinimo, _valorReferenciaMaximo, _maximoValorReferenciaMinimo, _maximoValorReferenciaMaximo);
    setState(() {});
  }

  void _altaPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKeyControl,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16.0),
                          Text(
                            'Nuevo Control:',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          SizedBox(height: 16.0),
                          TextFormField(
                            maxLength: 100,
                            controller: _nombreControlController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre Control',
                              hintText: 'Ingrese Nombre',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el nombre del control';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _nombreControl = value!;
                            },
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            maxLength: 100,
                            controller: _unidadControlController,
                            decoration: const InputDecoration(
                              labelText: 'Unidad',
                              hintText: 'Ingrese Unidad',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese la unidad del control';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _unidadControl = value!;
                            },
                          ),
                          SizedBox(height: 16.0),
                          CheckboxListTile(
                            title: Text("Valor Compuesto"),
                            value: _compuestoControl == 1,
                            onChanged: (newValue) {
                              setState(() {
                                _compuestoControl = newValue! ? 1 : 0;
                                _valorReferenciaMinimoController.clear();
                                _valorReferenciaMaximoController.clear();
                                _maximoValorReferenciaMaximoController.clear();
                                _maximoValorReferenciaMinimoController.clear();
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_compuestoControl == 0) ...[
                            SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese valor minimo:',
                                hintText: 'Valor minimo control',
                              ),
                              maxLength: 100,
                              controller: _valorReferenciaMinimoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor minimo del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _valorReferenciaMinimo = double.parse(value!);
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese valor maximo:',
                                hintText: 'Valor maximo control',
                              ),
                              maxLength: 100,
                              controller: _valorReferenciaMaximoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor maximo del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _valorReferenciaMaximo = double.parse(value!);
                              },
                            ),
                          ] else ...[
                            SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese valor minimo1:',
                                hintText: 'Valor minimo control',
                              ),
                              maxLength: 100,
                              controller: _valorReferenciaMinimoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor minimo del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _valorReferenciaMinimo = double.parse(value!);
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese valor maximo1:',
                                hintText: 'Valor maximo control',
                              ),
                              maxLength: 100,
                              controller: _valorReferenciaMaximoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor maximo del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _valorReferenciaMaximo = double.parse(value!);
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese valor minimo2:',
                                hintText: 'Valor minimo control',
                              ),
                              maxLength: 100,
                              controller: _maximoValorReferenciaMinimoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor minimo del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _maximoValorReferenciaMinimo = double.parse(value!);
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese valor maximo2:',
                                hintText: 'Valor maximo control',
                              ),
                              maxLength: 100,
                              controller: _maximoValorReferenciaMaximoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor maximo del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _maximoValorReferenciaMaximo = double.parse(value!);
                              },
                            ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKeyControl.currentState!.validate()) {
                                    _formKeyControl.currentState!.save();
                                    _registrarControl();
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Registrar Control'),
                              ),
                              SizedBox(width: 8.0), // Ajusta la separación entre los botones según tus necesidades
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            );
          },
        );
      },
    );
  }

  void _mostrarPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lista de controles:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: FutureBuilder<List<Control>?>(
                        future: _controles,
                        builder: (BuildContext context, AsyncSnapshot<List<Control>?> snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: snapshot.data!
                                  .map((control) => CheckboxListTile(
                                        title: Text(control.nombre),
                                        value: _selectedControles.contains(control),
                                        onChanged: (newValue) {
                                          setState(() {
                                            if (newValue!) {
                                              _selectedControles.add(control);
                                            } else {
                                              _selectedControles.remove(control);
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedControles = _selectedControles;
                            });
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedControles = _selectedControles;
                            });
                          },
                          child: const Text('Confirmar Selección'),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _nombreControlController.clear();
                            _unidadControlController.clear();
                            _valorReferenciaMinimoController.clear();
                            _valorReferenciaMaximoController.clear();
                            _maximoValorReferenciaMaximoController.clear();
                            _maximoValorReferenciaMinimoController.clear();
                            _compuestoControl = 0;
                            _altaPopUp();
                          },
                          child: const Text('Nuevo Control'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (_selectedControles.isNotEmpty) {
        setState(() {});
      }
    });
  }
}
