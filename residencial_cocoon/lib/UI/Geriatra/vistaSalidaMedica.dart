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
  ControllerVistaSalidaMedica? controller;
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  bool residentesVisible = false;
  String descripcion = '';
  DateTime? fechaDesde;
  DateTime? fechaHasta;
  List<Usuario>? _residentes = [];
  final fieldDescripcion = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaSalidaMedica(mostrarMensaje, limpiar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alta salida medica',
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
    await controller?.altaSalidaMedica(selectedResidente, descripcion,
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
      _residentes = [];
    });
  }
}
