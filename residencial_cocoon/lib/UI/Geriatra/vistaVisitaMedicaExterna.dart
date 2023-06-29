import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaSalidaMedica.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaVisitaMedicaExterna.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisitaMedicaExterna.dart';

class VistaVisitaMedicaExterna extends StatefulWidget {
  @override
  State<VistaVisitaMedicaExterna> createState() =>
      _VistaVisitaMedicaExternaState();
}

class _VistaVisitaMedicaExternaState extends State<VistaVisitaMedicaExterna>
    implements IvistaVisitaMedicaExterna {
  final _formKey = GlobalKey<FormState>();
  ControllerVistaVisitaMedicaExterna? controller;
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  bool residentesVisible = false;
  String descripcion = '';
  DateTime? fecha;
  List<Usuario>? _residentes = [];
  final fieldDescripcion = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaVisitaMedicaExterna(mostrarMensaje, limpiar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alta Visita Médica Externa',
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Seleccione la sucursal:"),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FutureBuilder<List<Sucursal>?>(
                    future: listaSucursales(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error al cargar las sucursales');
                      } else {
                        List<Sucursal>? sucursales = snapshot.data;
                        return Column(
                          children: sucursales?.map((Sucursal sucursal) {
                                return RadioListTile<Sucursal>(
                                  title: Text(sucursal.nombre),
                                  value: sucursal,
                                  groupValue: selectedSucursal,
                                  onChanged: (Sucursal? newValue) {
                                    setState(() {
                                      selectedSucursal = newValue;
                                      residentesVisible = true;
                                      _obtenerListaResidentes();
                                    });
                                  },
                                );
                              }).toList() ??
                              [],
                        );
                      }
                    },
                  ),
                ),
                // Mostrar el desplegable de residentes si es visible

                Column(
                  children: [
                    if (residentesVisible &&
                        _residentes!
                            .isNotEmpty) // Mostrar el desplegable de residentes si es visible y hay residentes disponibles
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Seleccione un residente:"),
                      ),
                    Column(
                      children: _residentes!.map((Usuario residente) {
                        return RadioListTile<Usuario>(
                          title:
                              Text(residente.nombre + " Ci: " + residente.ci),
                          value: residente,
                          groupValue: selectedResidente,
                          onChanged: (Usuario? newValue) {
                            setState(() {
                              selectedResidente = newValue;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Ingrese una descripción:"),
                ),
                TextFormField(
                  controller: fieldDescripcion,
                  onSaved: (value) {
                    descripcion = value!;
                  },
                  decoration: InputDecoration(
                    hintText: 'Descripción',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripcion';
                    }
                    return null;
                  },
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
                      fecha != null
                          ? DateFormat('dd/MM/yyyy').format(fecha!)
                          : 'Seleccione una fecha',
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
                  child: Text('Ingresar alta'),
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

  @override
  Future<List<Sucursal>?> listaSucursales() async {
    return controller?.listaSucursales();
  }

  Future<void> _obtenerListaResidentes() async {
    List<Usuario>? residentes = await listaResidentes(selectedSucursal);
    setState(() {
      _residentes = residentes;
    });
  }

  @override
  Future<List<Usuario>?> listaResidentes(Sucursal? suc) async {
    final residentes = await controller?.listaResidentes(suc);
    return residentes;
  }

  @override
  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Future<void> altaVisitaMedicaExt() async {
    await controller?.altaVisitaMedicaExt(
        selectedResidente, descripcion, fecha, selectedSucursal);
  }

  @override
  void limpiar() {
    setState(() {
      fieldDescripcion.clear();
      fecha = null;
      selectedResidente = null;
      selectedSucursal = null;
      residentesVisible = false;
      _residentes = [];
    });
  }
}
