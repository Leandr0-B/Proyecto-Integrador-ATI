import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaStockMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaStockMedicamento.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaStockMedicamento extends StatefulWidget {
  @override
  State<VistaStockMedicamento> createState() => _VistaStockMedicamentoState();
}

class _VistaStockMedicamentoState extends State<VistaStockMedicamento> implements IvistaStockMedicamento {
  ControllerVistaStockMedicamento _controller = ControllerVistaStockMedicamento.empty();
  final _formKey = GlobalKey<FormState>();
  final _formKeyFamiliar = GlobalKey<FormState>();
  Future<int> _cantidadDePaginas = Future.value(0);
  int _paginaActual = 1;
  int _elementosPorPagina = 3;
  String? _palabraClave = "";
  String? _ciResidente;
  String? _ciFamiliar;
  Future<List<PrescripcionDeMedicamento>?> _prescripciones = Future.value([]);
  Future<List<Familiar>?> _familiares = Future.value([]);
  Familiar? _selectedFamiliar;
  PrescripcionDeMedicamento? _selectedPrescripcion;
  int _stock = 0;
  int _stockNotificacion = 0;
  String _ciFamiliarAlta = '';
  String _nombreFamiliarAlta = '';
  String _apellidoFamiliarAlta = '';
  String _emailFamiliarAlta = '';
  String _telefonoFamiliarAlta = '';

  final _palabraClaveController = TextEditingController();
  final _ciResidenteController = TextEditingController();
  final _ciFamiliarController = TextEditingController();
  final _fieldStock = TextEditingController();
  final _fieldStockNotificacion = TextEditingController();
  final _ciFamiliarAltaController = TextEditingController();
  final _nombreFamiliarAltaController = TextEditingController();
  final _apellidoFamiliarAltaController = TextEditingController();
  final _emailFamiliarAltaController = TextEditingController();
  final _telefonoFamiliarAltaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaStockMedicamento(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alta Stock Medicamento',
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
                Column(
                  children: [
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _selectedFamiliar = null;
                        _selectedPrescripcion = null;
                        _fieldStock.clear();
                        _fieldStockNotificacion.clear();
                        limpiarFiltrosPrescripciones();
                        obtenerPrescripcionesActivasPaginadosConfiltros();
                        mostrarPopUpPrescripciones(_prescripciones);
                      },
                      child: Text('Seleccionar Prescripción'),
                    ),
                    if (_selectedPrescripcion != null) ...[
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Prescripción seleccionada: "),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedPrescripcion.toString(),
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _selectedFamiliar = null;
                          limpiarFiltrosFamiliares();
                          obtenerFamiliaresPaginadosConfiltros();
                          mostrarPopUpFamiliares(_familiares);
                        },
                        child: Text('Seleccionar Familiar'),
                      ),
                    ],
                    if (_selectedFamiliar != null) ...[
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Familiar seleccionado: "),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedFamiliar.toString(),
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Ingrese la cantidad:',
                          hintText: 'Cantidad de medicamento',
                        ),
                        maxLength: 100,
                        controller: _fieldStock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la cantidad.';
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
                          _stock = int.parse(value!);
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Ingrese la cantidad de notificación:',
                          hintText: 'Cantidad para notificación',
                        ),
                        maxLength: 100,
                        controller: _fieldStockNotificacion,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la cantidad para notificación.';
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
                          _stockNotificacion = int.parse(value!);
                        },
                      ),
                    ],
                  ],
                ),
                if (_selectedFamiliar != null) ...[
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        cargarStock();
                      }
                    },
                    child: Text('Actualizar Stock'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> cargarStock() async {
    await _controller.cargarStock(_selectedPrescripcion, _stock, _stockNotificacion, _selectedFamiliar);
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    setState(() {
      _selectedPrescripcion = null;
      _selectedFamiliar = null;
      _fieldStockNotificacion.clear();
      _fieldStock.clear();
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

  void obtenerFamiliaresPaginadosConfiltros() {
    _familiares = _controller.obtenerFamiliaresPaginadosConfiltros(_paginaActual, _elementosPorPagina, _selectedPrescripcion?.residente.usuario.ci, _ciFamiliar);
    _cantidadDePaginas = _controller.calcularTotalPaginasFamiliares(_elementosPorPagina, _selectedPrescripcion?.residente.usuario.ci, _ciFamiliar);
    setState(() {});
  }

  void obtenerPrescripcionesActivasPaginadosConfiltros() {
    _prescripciones = _controller.obtenerPrescripcionesActivasPaginadosConfiltros(_paginaActual, _elementosPorPagina, _ciResidente, _palabraClave);
    _cantidadDePaginas = _controller.calcularTotalPaginas(_elementosPorPagina, _ciResidente, _palabraClave);
    setState(() {});
  }

  void obtenerPrescripcionesActivasPaginadosBotonFiltrar() {
    _paginaActual = 1;
    obtenerPrescripcionesActivasPaginadosConfiltros();
  }

  void obtenerFamiliaresPaginadosBotonFiltrar() {
    _paginaActual = 1;
    obtenerFamiliaresPaginadosConfiltros();
  }

  void limpiarFiltrosPrescripciones() {
    _paginaActual = 1;
    _palabraClave = null;
    _ciResidente = null;
    _palabraClaveController.clear();
    _ciResidenteController.clear();
  }

  void limpiarFiltrosFamiliares() {
    _paginaActual = 1;
    _ciFamiliar = null;
    _ciFamiliarController.clear();
  }

  void limpiarAltaFamiliar() {
    _ciFamiliarAltaController.clear();
    _nombreFamiliarAltaController.clear();
    _apellidoFamiliarAltaController.clear();
    _emailFamiliarAltaController.clear();
    _telefonoFamiliarAltaController.clear();
  }

  Future<void> altaFamiliar() async {
    await _controller.altaFamiliar(
        _selectedPrescripcion?.residente.usuario.ci, _ciFamiliarAlta, _nombreFamiliarAlta, _apellidoFamiliarAlta, _emailFamiliarAlta, _telefonoFamiliarAlta);
  }

  void mostrarPopUpPrescripciones(Future<List<PrescripcionDeMedicamento>?> elementos) {
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
                            decoration: const InputDecoration(
                              labelText: 'Ci Residente',
                            ),
                            controller: _ciResidenteController,
                            onChanged: (value) {
                              setState(() {
                                _ciResidente = value;
                              });
                            },
                          ),
                        ),
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
                              obtenerPrescripcionesActivasPaginadosBotonFiltrar();
                            });
                          },
                          child: const Text('Filtrar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Lista de prescripciónes activas:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: FutureBuilder<List<PrescripcionDeMedicamento>?>(
                        future: _prescripciones,
                        builder: (BuildContext context, AsyncSnapshot<List<PrescripcionDeMedicamento>?> snapshot) {
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
                                        'No hay prescripciones cargados en el sistema.',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              final List<PrescripcionDeMedicamento>? lista = snapshot.data;
                              return ListView.separated(
                                shrinkWrap: true,
                                itemCount: lista?.length ?? 0,
                                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8.0),
                                itemBuilder: (BuildContext context, int index) {
                                  final PrescripcionDeMedicamento elemento = snapshot.data![index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPrescripcion = elemento;
                                      });
                                      Navigator.of(context).pop();
                                      setState(() {
                                        _fieldStock.text = _selectedPrescripcion!.medicamento.stock.toString();
                                        _fieldStockNotificacion.text = _selectedPrescripcion!.medicamento.stockNotificacion.toString();
                                      });
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
                                                  obtenerPrescripcionesActivasPaginadosConfiltros();
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
                                                  obtenerPrescripcionesActivasPaginadosConfiltros();
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
      if (_selectedPrescripcion != null) {
        setState(() {});
      }
    });
  }

  void mostrarPopUpFamiliares(Future<List<Familiar>?> elementos) {
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
                            decoration: const InputDecoration(
                              labelText: 'Ci familiar',
                            ),
                            controller: _ciFamiliarController,
                            onChanged: (value) {
                              setState(() {
                                _ciFamiliar = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              obtenerFamiliaresPaginadosBotonFiltrar();
                            });
                          },
                          child: const Text('Filtrar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Lista de familiares:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: FutureBuilder<List<Familiar>?>(
                        future: _familiares,
                        builder: (BuildContext context, AsyncSnapshot<List<Familiar>?> snapshot) {
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
                                        'No hay familiares cargados en el sistema para este residente.',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              final List<Familiar>? lista = snapshot.data;
                              return ListView.separated(
                                shrinkWrap: true,
                                itemCount: lista?.length ?? 0,
                                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8.0),
                                itemBuilder: (BuildContext context, int index) {
                                  final Familiar elemento = snapshot.data![index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFamiliar = elemento;
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                limpiarAltaFamiliar();
                                altaPopUp();
                              },
                              child: const Text('Nuevo Familiar'),
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
                                                  obtenerFamiliaresPaginadosConfiltros();
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
                                                  obtenerFamiliaresPaginadosConfiltros();
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
      if (_selectedFamiliar != null) {
        setState(() {});
      }
    });
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
                    key: _formKeyFamiliar,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16.0),
                          Text(
                            'Nuevo Familiar:',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          SizedBox(height: 16.0),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Documento del familiar',
                              hintText: 'Ingrese CI del Familiar',
                            ),
                            maxLength: 30,
                            controller: _ciFamiliarAltaController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese CI del Familiar';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _ciFamiliarAlta = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nombre del familiar',
                              hintText: 'Ingrese Nombre del Familiar',
                            ),
                            maxLength: 100,
                            controller: _nombreFamiliarAltaController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese Nombre del Familiar';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _nombreFamiliarAlta = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Apellido del familiar',
                              hintText: 'Ingrese Apellido del Familiar',
                            ),
                            maxLength: 100,
                            controller: _apellidoFamiliarAltaController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese Apellido del Familiar';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _apellidoFamiliarAlta = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email del familiar',
                              hintText: 'Ingrese Email del Familiar (ejemplo@ejemplo.ejem)',
                            ),
                            maxLength: 100,
                            controller: _emailFamiliarAltaController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese Email del Familiar';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _emailFamiliarAlta = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Telefono familiar',
                              hintText: 'Ingrese telefono',
                            ),
                            maxLength: 100,
                            controller: _telefonoFamiliarAltaController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el telefono.';
                              }
                              if (num.tryParse(value) == null) {
                                return 'Solo puede ingresar valores nueméricos.';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _telefonoFamiliarAlta = value!;
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKeyFamiliar.currentState!.validate()) {
                                    _formKeyFamiliar.currentState!.save();
                                    altaFamiliar();
                                    limpiarAltaFamiliar();
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Registrar Familiar'),
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
}
