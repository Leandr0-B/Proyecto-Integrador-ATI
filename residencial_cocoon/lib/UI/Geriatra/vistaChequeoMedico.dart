import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaChequeoMedico.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaChequeoMedico.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaChequeoMedico extends StatefulWidget {
  @override
  State<VistaChequeoMedico> createState() => _VistaChequeoMedicoState();
}

class _VistaChequeoMedicoState extends State<VistaChequeoMedico> implements IvistaChequeoMedico {
  DateTime? fecha;
  final _formKey = GlobalKey<FormState>();
  String descripcion = '';
  final fieldDescripcion = TextEditingController();
  //final fieldValor = TextEditingController();
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  bool residentesVisible = false;
  List<Control?> selectedControles = [];
  Control? selectedControl;
  ControllerVistaChequeoMedico controller = ControllerVistaChequeoMedico.empty();
  //String valor = '';
  TimeOfDay? _hora;

  double _primerValor = 0;
  double _segundoValor = 0;
  final _fieldPrimerValor = TextEditingController();
  final _fieldSegundoValor = TextEditingController();
  final _formKeyControl = GlobalKey<FormState>();

  bool agregarControles = false;

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaChequeoMedico(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Chequeo Médico',
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione la hora:"),
                ),
                InkWell(
                  onTap: () => _selectHora(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Hora',
                    ),
                    child: Text(
                      _hora != null ? _hora!.format(context) : 'Seleccione una hora',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Ingrese una descripción del control:"),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: TextFormField(
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
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      border: InputBorder.none, // Elimina el borde predeterminado del TextFormField
                    ),
                  ),
                ),
                SizedBox(height: 10),
                CheckboxListTile(
                  title: Text("¿Desea agregar controles?"),
                  value: agregarControles,
                  onChanged: (newValue) {
                    setState(() {
                      agregarControles = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (agregarControles) // Mostrar el segmento de código solo si agregarControles es verdadero
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Tipo Control:"),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FutureBuilder<List<Control>?>(
                          future: listaControles(),
                          builder: (BuildContext context, AsyncSnapshot<List<Control>?> snapshot) {
                            if (snapshot.hasData) {
                              List<Control> controles = snapshot.data!;
                              return DropdownButton<Control>(
                                value: selectedControl,
                                items: [
                                  DropdownMenuItem<Control>(
                                    value: null, // Valor predeterminado cuando no se ha seleccionado ningún control
                                    child: Text("Seleccione control"),
                                  ),
                                  ...controles.map((control) {
                                    return DropdownMenuItem<Control>(
                                      value: control,
                                      child: Text(control.nombre),
                                    );
                                  }),
                                ],
                                onChanged: (Control? newValue) {
                                  setState(() {
                                    _fieldSegundoValor.clear();
                                    _fieldPrimerValor.clear();
                                    selectedControl = newValue;
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
                      SizedBox(height: 10),
                      Container(
                        child: Form(
                          key: _formKeyControl,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selectedControl?.valor_compuesto == 0) ...[
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Ingrese valor:',
                                      hintText: 'Valor del control',
                                    ),
                                    maxLength: 100,
                                    controller: _fieldPrimerValor,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese el valor del control.';
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
                                      _primerValor = double.parse(value!);
                                    },
                                  ),
                                ] else ...[
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Ingrese primer valor:',
                                      hintText: 'Valor del control',
                                    ),
                                    maxLength: 100,
                                    controller: _fieldPrimerValor,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese el valor del control.';
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
                                      _primerValor = double.parse(value!);
                                    },
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Ingrese el segundo valor:',
                                      hintText: 'Valor del control',
                                    ),
                                    maxLength: 100,
                                    controller: _fieldSegundoValor,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese el valor del control.';
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
                                      _segundoValor = double.parse(value!);
                                    },
                                  ),
                                ],
                                SizedBox(height: 10),
                                if (selectedControles != null && selectedControles!.isNotEmpty)
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Lista de controles"),
                                  ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: selectedControles?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final control = selectedControles![index];
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          Text(
                                              '${control?.nombre} ${control?.unidad} ${control?.valor_compuesto == 1 ? "${control?.valor} - ${control?.segundoValor}" : control?.valor}'),
                                          IconButton(
                                            icon: Icon(Icons.remove_circle),
                                            onPressed: () {
                                              _eliminarControl(index);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  child: Text("Agregar control"),
                                  onPressed: () {
                                    if (_formKeyControl.currentState!.validate()) {
                                      _formKeyControl.currentState!.save();
                                      _agregarControl(selectedControl, _primerValor, _segundoValor);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                SizedBox(height: 10),
                ElevatedButton(
                  child: Text("Alta Chequeo"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      altaChequeoMedico();
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

  Future<void> _selectHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _hora) {
      setState(() {
        _hora = picked;
      });
    }
  }

  Future<void> _selectFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fecha ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != fecha) {
      setState(() {
        fecha = picked;
      });
    }
  }

  void _eliminarControl(int index) {
    setState(() {
      selectedControles.removeAt(index);
    });
  }

  void _agregarControl(Control? control, double primerValor, double segundoValor) {
    setState(() {
      controller.altaSelectedControl(control, primerValor, segundoValor, selectedControles);
    });
  }

  @override
  void limpiar() {
    setState(() {
      fieldDescripcion.clear();
      _fieldSegundoValor.clear();
      _fieldPrimerValor.clear();
      fecha = null;
      _hora = null;
      selectedResidente = null;
      selectedSucursal = null;
      residentesVisible = false;
      agregarControles = false;
      selectedControles = [];
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

  @override
  Future<void> altaChequeoMedico() async {
    await controller.altaChequeoMedico(selectedSucursal, selectedResidente, selectedControles, fecha, _hora, descripcion, agregarControles);
  }

  @override
  Future<List<Usuario>?> listaResidentes() async {
    return await controller.listaResidentes(selectedSucursal);
  }

  @override
  Future<List<Sucursal>?> listaSucursales() async {
    return await controller.listaSucursales();
  }

  @override
  Future<List<Control>?> listaControles() async {
    return await controller.listaControles();
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }
}
