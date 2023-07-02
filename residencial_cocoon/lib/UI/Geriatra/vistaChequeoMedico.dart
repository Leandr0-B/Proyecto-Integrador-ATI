import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaChequeoMedico.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaChequeoMedico.dart';

class VistaChequeoMedico extends StatefulWidget {
  @override
  State<VistaChequeoMedico> createState() => _VistaChequeoMedicoState();
}

class _VistaChequeoMedicoState extends State<VistaChequeoMedico> implements IvistaChequeoMedico {
  DateTime? fecha;
  final _formKey = GlobalKey<FormState>();
  String descripcion = '';
  final fieldDescripcion = TextEditingController();
  final fieldValor = TextEditingController();
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  bool residentesVisible = false;
  List<Control?> selectedControles = [];
  Control? selectedControl;
  ControllerVistaChequeoMedico controller = ControllerVistaChequeoMedico.empty();
  String valor = '';
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
          'Alta de Chequeo Médico',
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
                                      child: Text(residente.nombre + ' | ' + residente.ci),
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
                  child: Text("Ingrese una descripción del control:"),
                ),
                TextFormField(
                  controller: fieldDescripcion,
                  onSaved: (value) {
                    descripcion = value!;
                  },
                  decoration: InputDecoration(
                    hintText: 'Descripción del control',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripcion';
                    }
                    return null;
                  },
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Ingrese valor del control:"),
                      ),
                      TextFormField(
                        controller: fieldValor,
                        onSaved: (value) {
                          valor = value!;
                        },
                        decoration: InputDecoration(
                          hintText: 'Valor control:',
                        ),
                      ),
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
                                Text('${control?.nombre} ${control?.valor}'),
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
                          if (fieldValor.text.isNotEmpty) {
                            _formKey.currentState!.save();
                            _agregarControl(selectedControl, valor);
                          } else {
                            mostrarMensaje("Tiene que ingresar un valor.");
                          }
                        },
                      ),
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

  void _agregarControl(Control? control, String valor) {
    setState(() {
      controller.altaSelectedControl(control, valor, selectedControles);
    });
  }

  @override
  void limpiar() {
    setState(() {
      fieldDescripcion.clear();
      fieldValor.clear();
      fecha = null;
      selectedResidente = null;
      selectedSucursal = null;
      residentesVisible = false;
      agregarControles = false;
      selectedControles = [];
    });
  }

  @override
  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Future<void> altaChequeoMedico() async {
    await controller.altaChequeoMedico(selectedSucursal, selectedResidente, selectedControles, fecha, descripcion);
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
}
