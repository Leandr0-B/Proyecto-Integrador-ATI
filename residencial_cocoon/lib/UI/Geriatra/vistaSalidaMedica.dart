import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaSalidaMedica.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaSalidaMedica.dart';

class VistaSalidaMedica extends StatefulWidget {
  @override
  State<VistaSalidaMedica> createState() => _VistaSalidaMedicaState();
}

class _VistaSalidaMedicaState extends State<VistaSalidaMedica>
    implements IvistaSalidaMedica {
  final _formKey = GlobalKey<FormState>();
  ControllerVistaSalidaMedica controller = ControllerVistaSalidaMedica.empty();
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  bool residentesVisible = false;
  String descripcion = '';
  DateTime? fechaDesde;
  DateTime? fechaHasta;
  final fieldDescripcion = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaSalidaMedica(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alta Salida Médica',
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
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Sucursal>?> snapshot) {
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
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Usuario>?> snapshot) {
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
                                      child: Text(residente.nombre +
                                          ' | ' +
                                          residente.ci),
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
                  child: TextFormField(
                    controller: fieldDescripcion,
                    maxLines: null,
                    onChanged: (value) {
                      descripcion = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Descripción',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      border: InputBorder
                          .none, // Elimina el borde predeterminado del TextFormField
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione una fecha desde:"),
                ),
                InkWell(
                  onTap: () => _selectFechaDesde(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Fecha desde',
                    ),
                    child: Text(
                      fechaDesde != null
                          ? DateFormat('dd/MM/yyyy').format(fechaDesde!)
                          : 'Seleccione una fecha',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione una fecha hasta:"),
                ),
                InkWell(
                  onTap: () => _selectFechaHasta(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Fecha hasta',
                    ),
                    child: Text(
                      fechaHasta != null
                          ? DateFormat('dd/MM/yyyy').format(fechaHasta!)
                          : 'Seleccione una fecha',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      altaSalidaMedica();
                    }
                  },
                  child: Text('Ingresar alta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Future<List<Sucursal>?> listaSucursales() async {
    return controller.listaSucursales();
  }

  @override
  Future<List<Usuario>?> listaResidentes() async {
    return await controller.listaResidentes(selectedSucursal);
  }

  Future<void> _selectFechaDesde(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaDesde ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != fechaDesde) {
      setState(() {
        fechaDesde = picked;
      });
    }
  }

  Future<void> _selectFechaHasta(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaHasta ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != fechaHasta) {
      setState(() {
        fechaHasta = picked;
      });
    }
  }

  @override
  Future<void> altaSalidaMedica() async {
    await controller.altaSalidaMedica(selectedResidente, descripcion,
        fechaDesde, fechaHasta, selectedSucursal);
  }

  @override
  void limpiar() {
    setState(() {
      fieldDescripcion.clear();
      fechaDesde = null;
      fechaHasta = null;
      selectedResidente = null;
      selectedSucursal = null;
      residentesVisible = false;
    });
  }
}
