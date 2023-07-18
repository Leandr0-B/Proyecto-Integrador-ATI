import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaPrescripcionMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaPrescripcionMedicamento.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaPrescripcionMedicamento extends StatefulWidget {
  @override
  State<VistaPrescripcionMedicamento> createState() => _VistaPrescripcionMedicamentoState();
}

class _VistaPrescripcionMedicamentoState extends State<VistaPrescripcionMedicamento> implements IvistaPrescripcionMedicamento {
  ControllerVistaPrescripcionMedicamento _controller = ControllerVistaPrescripcionMedicamento.empty();
  final _formKey = GlobalKey<FormState>();
  Usuario? _selectedResidente;
  Sucursal? _selectedSucursal;
  Medicamento? _selectedMedicamento;
  DateTime? _fecha_desde;
  DateTime? _fecha_hasta;
  TimeOfDay? _hora_comienzo;
  String _descripcion = "";
  int _frecuencia = 0;
  int _cantidad = 0;
  String _palabraClave = "";
  Future<List<Medicamento>?> _medicamentos = Future.value([]);
  Future<int> _cantidadDePaginas = Future.value(0);
  int _paginaActual = 1;
  int _elementosPorPagina = 5;
  bool _residentesVisible = false;

  final _fieldDescripcion = TextEditingController();
  final _fieldFrecuencia = TextEditingController();
  final _fieldCantidad = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaPrescripcionMedicamento(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prescripcion medicamento',
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
                                _residentesVisible = true;
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
                    if (_residentesVisible) ...[
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
                                      child: Text(residente.nombre + " " + residente.apellido + ' | ' + residente.ci),
                                    );
                                  }),
                                ],
                                onChanged: (Usuario? newValue) {
                                  setState(() {
                                    _selectedResidente = newValue;
                                    _selectedMedicamento = null;
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
                            _selectedMedicamento = null;
                            obtenerMedicamentosPaginadosConfiltros();
                            mostrarPopUp(_medicamentos);
                          },
                          child: Text('Seleccionar medicamento'),
                        ),
                      ],
                      if (_selectedMedicamento != null) ...[
                        SizedBox(height: 10),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text("Medicamento seleccionado: "),
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _selectedMedicamento.toString(),
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
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
                          child: TextFormField(
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
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 12.0,
                              ),
                              border: InputBorder.none, // Elimina el borde predeterminado del TextFormField
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Ingrese la frecuencia en horas:',
                            hintText: 'Frecuencia de consumo en horas',
                          ),
                          maxLength: 100,
                          controller: _fieldFrecuencia,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la frecuencia de consumo.';
                            }
                            if (num.tryParse(value) == null) {
                              return 'Solo puede ingresar valores numéricos.';
                            }
                            if (num.tryParse(value)! < 0) {
                              return 'Solo puede ingresar valores positivos.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _frecuencia = int.parse(value!);
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Ingrese la cantidad del consumo:',
                            hintText: 'Cantidad del consumo del medicamento',
                          ),
                          maxLength: 100,
                          controller: _fieldCantidad,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la cantidad del consumo del medicamento.';
                            }
                            if (num.tryParse(value) == null) {
                              return 'Solo puede ingresar valores numéricos.';
                            }
                            if (num.tryParse(value)! < 0) {
                              return 'Solo puede ingresar valores positivos.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _cantidad = int.parse(value!);
                          },
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Seleccione la fecha desde:"),
                        ),
                        InkWell(
                          onTap: () => _selectFechaDesde(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'Fecha',
                            ),
                            child: Text(
                              _fecha_desde != null ? DateFormat('dd/MM/yyyy').format(_fecha_desde!) : 'Seleccione una fecha',
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Seleccione la fecha hasta:"),
                        ),
                        InkWell(
                          onTap: () => _selectFechaHasta(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'Fecha',
                            ),
                            child: Text(
                              _fecha_hasta != null ? DateFormat('dd/MM/yyyy').format(_fecha_hasta!) : 'Seleccione una fecha',
                            ),
                          ),
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
                      ]
                    ],
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _selectedMedicamento = _selectedMedicamento;
                      registrarPrescripcion();
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
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    setState(() {
      _fieldCantidad.clear();
      _fieldDescripcion.clear();
      _fieldFrecuencia.clear();
      _selectedMedicamento = null;
      _selectedResidente = null;
      _selectedSucursal = null;
      _residentesVisible = false;
      _fecha_desde = null;
      _fecha_hasta = null;
      _hora_comienzo = null; /////////////
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
  void obtenerMedicamentosPaginadosBotonFiltrar() {
    _paginaActual = 1;
    obtenerMedicamentosPaginadosConfiltros();
  }

  @override
  void obtenerMedicamentosPaginadosConfiltros() {
    _medicamentos = _controller.listaMedicamentos(_paginaActual, _elementosPorPagina, _selectedResidente!, _palabraClave);
    _cantidadDePaginas = _controller.calcularTotalPaginas(_elementosPorPagina, _selectedResidente?.ci, _palabraClave);
    setState(() {});
  }

  @override
  Future<void> registrarPrescripcion() async {
    await _controller.registrarPrescripcion(
        _selectedMedicamento, _selectedResidente, _selectedSucursal, _cantidad, _descripcion, _fecha_desde, _fecha_hasta, _frecuencia, _hora_comienzo);
  }

  Future<void> _selectFechaDesde(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha_desde ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _fecha_desde) {
      setState(() {
        _fecha_desde = picked;
      });
    }
  }

  Future<void> _selectFechaHasta(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha_hasta ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _fecha_hasta) {
      setState(() {
        _fecha_hasta = picked;
      });
    }
  }

  Future<void> _selectHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _hora_comienzo ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _hora_comienzo) {
      setState(() {
        _hora_comienzo = picked;
      });
    }
  }

  void mostrarPopUp(Future<List<Medicamento>?> elementos) {
    final TextEditingController textFieldController = TextEditingController();
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: textFieldController,
                            decoration: const InputDecoration(
                              labelText: 'Palabra clave',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _palabraClave = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              obtenerMedicamentosPaginadosBotonFiltrar();
                            });
                          },
                          child: const Text('Filtrar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Lista de elementos:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: FutureBuilder<List<Medicamento>?>(
                        future: _medicamentos,
                        builder: (BuildContext context, AsyncSnapshot<List<Medicamento>?> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final List<Medicamento>? lista = snapshot.data;
                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: lista?.length ?? 0,
                              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8.0),
                              itemBuilder: (BuildContext context, int index) {
                                final Medicamento elemento = snapshot.data![index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedMedicamento = elemento;
                                    });
                                    Navigator.of(context).pop();
                                    setState(() {});
                                    // Cerrar el diálogo y actualizar el estado
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      elemento.toString(),
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cerrar'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<int>(
                          future: Future.value(_cantidadDePaginas),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text(''); // Muestra un mensaje de error si hay un problema al obtener cantidadDePaginas
                            } else {
                              final int totalPagesValue = snapshot.data ?? 0;
                              return totalPagesValue == 0
                                  ? Container()
                                  : Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back),
                                          onPressed: _paginaActual == 1
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _paginaActual--;
                                                  });
                                                  obtenerMedicamentosPaginadosConfiltros();
                                                },
                                        ),
                                        Text('$_paginaActual/$totalPagesValue'),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_forward),
                                          onPressed: _paginaActual == totalPagesValue
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _paginaActual++;
                                                  });
                                                  obtenerMedicamentosPaginadosConfiltros();
                                                },
                                        ),
                                      ],
                                    );
                            }
                          },
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
      if (_selectedMedicamento != null) {
        setState(() {});
      }
    });
  }
}