import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAsociarMedicamentoResidente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaAsociarMedicamentoResidente.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaAsociarMedicamento extends StatefulWidget {
  @override
  State<VistaAsociarMedicamento> createState() => _VistaPrescripcionMedicamentoState();
}

class _VistaPrescripcionMedicamentoState extends State<VistaAsociarMedicamento> implements IvistaAsociarMedicamento {
  ControllerVistaAsociarMedicamento _controller = ControllerVistaAsociarMedicamento.empty();
  final _formKey = GlobalKey<FormState>();
  Usuario? _selectedResidente;
  Sucursal? _selectedSucursal;
  Medicamento? _selectedMedicamento;
  bool residentesVisible = false;
  Future<List<Medicamento>?> _medicamentos = Future.value([]);
  Future<int> _cantidadDePaginas = Future.value(0);
  int _paginaActual = 1;
  int _elementosPorPagina = 10;
  String? _palabraClave = "";
  final _palabraClaveController = TextEditingController();

  //Medicamento Alta
  String _nombreMedicamento = "";
  String? _selectedUnidad;
  final _formKeyMedicamento = GlobalKey<FormState>();
  final _nombreMedicamentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaAsociarMedicamento(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asociar medicamento',
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
                                residentesVisible = true;
                                _palabraClaveController.clear();
                                _palabraClave = null;
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
                                    _palabraClaveController.clear();
                                    _palabraClave = null;
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
                      asociarMedicamento();
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
  Future<void> asociarMedicamento() async {
    await _controller.asociarMedicamento(_selectedMedicamento, _selectedResidente, _selectedSucursal);
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    setState(() {
      _selectedMedicamento = null;
      _selectedResidente = null;
      _selectedSucursal = null;
      residentesVisible = false;
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
  Future<List<Usuario>?> listaResidentes() async {
    return await _controller.listaResidentes(_selectedSucursal);
  }

  @override
  Future<List<Sucursal>?> listaSucursales() async {
    return await _controller.listaSucursales();
  }

  @override
  void obtenerMedicamentosPaginadosConfiltros() {
    _medicamentos = _controller.obtenerMedicamentosPaginadosConFiltros(_paginaActual, _elementosPorPagina, _palabraClave);
    _cantidadDePaginas = _controller.calcularTotalPaginas(_elementosPorPagina, _palabraClave);
    setState(() {});
  }

  @override
  void obtenerMedicamentosPaginadosBotonFiltrar() {
    _paginaActual = 1;
    obtenerMedicamentosPaginadosConfiltros();
  }

  Future<void> altaMedicamento() async {
    await _controller.altaMedicamento(_nombreMedicamento, _selectedUnidad);
  }

  void altaPopUp() {
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
                    key: _formKeyMedicamento,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16.0),
                          Text(
                            'Nuevo Medicamento:',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          SizedBox(height: 16.0),
                          TextFormField(
                            maxLength: 100,
                            controller: _nombreMedicamentoController,
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
                                  value: 'unidades',
                                  child: const Text('unidades'),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKeyMedicamento.currentState!.validate()) {
                                    _formKeyMedicamento.currentState!.save();
                                    altaMedicamento();
                                    _nombreMedicamentoController.clear();
                                    _selectedUnidad = null;
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Registrar Medicamento'),
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

  void mostrarPopUp(Future<List<Medicamento>?> elementos) {
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
                            controller: _palabraClaveController,
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
                      'Lista de medicamentos:',
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
                            if (snapshot.data!.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No hay medicamentos cargados en el sistema.',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              );
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
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            altaPopUp();
                          },
                          child: const Text('Nuevo Medicamento'),
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
