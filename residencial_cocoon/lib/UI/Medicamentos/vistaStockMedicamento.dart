import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int _elementosPorPagina = 6;
  String? _palabraClave = "";
  String? _ciResidente;

  String? _palabraClaveFiltro = "";
  String? _ciResidenteFiltro;

  Future<List<PrescripcionDeMedicamento>> _prescripciones = Future.value([]);
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
  bool _filtroExpandido = false;
  int _stockAnterior = 0;

  final _palabraClaveController = TextEditingController();
  final _ciResidenteController = TextEditingController();
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
    obtenerPrescripcionesActivasPaginadosConfiltros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alta Stock Medicamento',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(195, 190, 190, 180),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth >= 600) {
            // Dispositivo con ancho mayor o igual a 600 (tablet o pantalla grande)
            return buildWideLayout();
          } else {
            // Dispositivo con ancho menor a 600 (teléfono o pantalla pequeña)
            return buildNarrowLayout();
          }
        },
      ),
    );
  }

  Widget buildWideLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Palabra Clave',
                  ),
                  controller: _palabraClaveController,
                  onChanged: (value) {
                    setState(() {
                      _palabraClave = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerPrescripcionesActivasPaginadosBotonFiltrar();
                },
                child: const Text('Filtrar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    limpiarFiltros();
                    obtenerPrescripcionesPaginadas();
                  });
                },
                child: const Text('Mostrar Todos'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<PrescripcionDeMedicamento>>(
            future: _prescripciones,
            builder: (BuildContext context, AsyncSnapshot<List<PrescripcionDeMedicamento>> snapshot) {
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
                            'Aún no hay prescripciónes registradadas',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  );
                } else {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 16.0); // Espacio entre cada notificación
                    },
                    itemBuilder: (BuildContext context, int index) {
                      PrescripcionDeMedicamento prescripcion = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          _selectedPrescripcion = prescripcion;
                          _selectedFamiliar = null;
                          mostrarPopUp(prescripcion);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              shape: RoundedRectangleBorder(
                                // Borde más fuerte y ancho
                                borderRadius: BorderRadius.circular(8.0),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 0.25,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prescripción ${prescripcion.esCronica() ? 'Cronica' : 'Temporal'}, Residente: ${prescripcion.ciResidente()} - ${prescripcion.nombreResidente()} - ${prescripcion.apellidoResidente()}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Fecha Creacion: ${DateFormat('dd/MM/yyyy').format(prescripcion.fecha_creacion)}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Descripcion: ${prescripcion.descripcion}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Medicamento: ${prescripcion.medicamento.toString()}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Stock actual: ${prescripcion.stock}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<int>(
              future: _cantidadDePaginas, // _cantidadDePaginas es un Future<int>
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(''); // Muestra un mensaje de error si hay un problema al obtener _cantidadDePaginas
                } else {
                  final int totalPagesValue = snapshot.data ?? 0; // Obtiene el valor de _cantidadDePaginas
                  return totalPagesValue == 0
                      ? Container() // No muestra nada si _cantidadDePaginas es 0
                      : Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _paginaActual == 1
                                  ? null
                                  : () {
                                      setState(() {
                                        _paginaActual--;
                                        obtenerPrescripcionesActivasPaginadosConfiltros();
                                      });
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
                                        obtenerPrescripcionesActivasPaginadosConfiltros();
                                      });
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
    );
  }

  Widget buildNarrowLayout() {
    return Column(
      children: [
        ListTile(
          title: const Text('Filtros'),
          trailing: _filtroExpandido ? const Icon(Icons.keyboard_arrow_up) : const Icon(Icons.keyboard_arrow_down),
          onTap: () {
            setState(() {
              _filtroExpandido = !_filtroExpandido;
            });
          },
        ),
        if (_filtroExpandido) ...[
          TextFormField(
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
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Palabra Clave',
              ),
              controller: _palabraClaveController,
              onChanged: (value) {
                setState(() {
                  _palabraClave = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerPrescripcionesActivasPaginadosBotonFiltrar();
                },
                child: const Text('Filtrar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    limpiarFiltros();
                    obtenerPrescripcionesPaginadas();
                  });
                },
                child: const Text('Mostrar Todos'),
              ),
            ],
          ),
        ],
        Expanded(
          child: FutureBuilder<List<PrescripcionDeMedicamento>>(
            future: _prescripciones,
            builder: (BuildContext context, AsyncSnapshot<List<PrescripcionDeMedicamento>> snapshot) {
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
                            'Aún no hay prescripciónes registradadas',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  );
                } else {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 16.0,
                      ); // Espacio entre cada notificación
                    },
                    itemBuilder: (BuildContext context, int index) {
                      PrescripcionDeMedicamento prescripcion = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          mostrarPopUp(prescripcion);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              shape: RoundedRectangleBorder(
                                // Borde más fuerte y ancho
                                borderRadius: BorderRadius.circular(8.0),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 0.25,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prescripción ${prescripcion.esCronica() ? 'Cronica' : 'Temporal'}, Residente: ${prescripcion.ciResidente()} - ${prescripcion.nombreResidente()} - ${prescripcion.apellidoResidente()}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Fecha Creacion: ${DateFormat('dd/MM/yyyy').format(prescripcion.fecha_creacion)}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Descripcion: ${prescripcion.descripcion}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Medicamento: ${prescripcion.medicamento.toString()}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Stock actual: ${prescripcion.stock}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<int>(
              future: _cantidadDePaginas, // _cantidadDePaginas es un Future<int>
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(''); // Muestra un mensaje de error si hay un problema al obtener _cantidadDePaginas
                } else {
                  final int totalPagesValue = snapshot.data ?? 0; // Obtiene el valor de _cantidadDePaginas
                  return totalPagesValue == 0
                      ? Container() // No muestra nada si _cantidadDePaginas es 0
                      : Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _paginaActual == 1
                                  ? null
                                  : () {
                                      setState(() {
                                        _paginaActual--;
                                        obtenerPrescripcionesActivasPaginadosConfiltros();
                                      });
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
                                        obtenerPrescripcionesActivasPaginadosConfiltros();
                                      });
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
    );
  }

  @override
  Future<void> cargarStock() async {
    await _controller.cargarStock(_selectedPrescripcion, _stock, _stockNotificacion, _selectedFamiliar, _stockAnterior);
    setState(() {
      obtenerPrescripcionesActivasPaginadosConfiltros();
    });
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
      _stockAnterior = 0;
    });
  }

  void limpiarFiltros() {
    _paginaActual = 1;
    _palabraClave = null;
    _ciResidente = null;
    _palabraClaveFiltro = null;
    _ciResidenteFiltro = null;
    _palabraClaveController.clear();
    _ciResidenteController.clear();
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

  void listaFamiliares() {
    _familiares = _controller.obtenerFamiliaresPaginadosConfiltros(1, 20, _selectedPrescripcion?.residente.usuario.ci, null);
    setState(() {});
  }

  void obtenerPrescripcionesPaginadas() {
    limpiarFiltros();
    obtenerPrescripcionesActivasPaginadosConfiltros();
  }

  void obtenerPrescripcionesActivasPaginadosConfiltros() {
    _prescripciones = _controller.obtenerPrescripcionesActivasPaginadosConfiltros(_paginaActual, _elementosPorPagina, _ciResidenteFiltro, _palabraClaveFiltro);
    _cantidadDePaginas = _controller.calcularTotalPaginas(_elementosPorPagina, _ciResidenteFiltro, _palabraClaveFiltro);
    setState(() {});
  }

  void obtenerPrescripcionesActivasPaginadosBotonFiltrar() {
    _palabraClaveFiltro = _palabraClave;
    _ciResidenteFiltro = _ciResidente;
    _paginaActual = 1;
    obtenerPrescripcionesActivasPaginadosConfiltros();
  }

  void limpiarFiltrosPrescripciones() {
    _paginaActual = 1;
    _palabraClave = null;
    _ciResidente = null;
    _palabraClaveFiltro = null;
    _ciResidenteFiltro = null;
    _palabraClaveController.clear();
    _ciResidenteController.clear();
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

  void altaPopUp(PrescripcionDeMedicamento prescripcion) async {
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
                              if (num.tryParse(value) == null) {
                                return 'Solo puede ingresar valores nueméricos.';
                              } else if (num.tryParse(value)! <= 0) {
                                return 'Ingresar el documento identificador sin puntos ni guiones.';
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
                              // Expresión regular que permite solo letras (mayúsculas y minúsculas).
                              final RegExp regex = RegExp(r'^[a-zA-Z ]+$');
                              if (!regex.hasMatch(value)) {
                                return 'Por favor ingrese solo letras';
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
                              // Expresión regular que permite solo letras (mayúsculas y minúsculas).
                              final RegExp regex = RegExp(r'^[a-zA-Z ]+$');
                              if (!regex.hasMatch(value)) {
                                return 'Por favor ingrese solo letras';
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
                              } else if (num.tryParse(value)! <= 0) {
                                return 'No es un número de telefono válido';
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
                                onPressed: () async {
                                  if (_formKeyFamiliar.currentState!.validate()) {
                                    _formKeyFamiliar.currentState!.save();
                                    await altaFamiliar();
                                    limpiarAltaFamiliar();
                                    Navigator.of(context).pop(); // Cierra el altaPopUp() y regresa al mostrarPopUp()
                                    mostrarPopUp(prescripcion);
                                  }
                                },
                                child: const Text('Registrar Familiar'),
                              ),
                              SizedBox(width: 8.0), // Ajusta la separación entre los botones según tus necesidades
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  mostrarPopUp(prescripcion);
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

  void mostrarPopUp(PrescripcionDeMedicamento prescripcion) async {
    listaFamiliares();
    _fieldStockNotificacion.clear();
    _fieldStock.clear();
    _stockAnterior = 0;
    _fieldStockNotificacion.text = prescripcion.stockNotificacion.toString();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, // Ancho máximo deseado
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Prescripción ${prescripcion.esCronica() ? 'Cronica' : 'Temporal'}, Residente: ${prescripcion.ciResidente()} - ${prescripcion.nombreResidente()} - ${prescripcion.apellidoResidente()}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Fecha Creacion: ${DateFormat('dd/MM/yyyy').format(prescripcion.fecha_creacion)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Descripcion: ${prescripcion.descripcion}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Medicamento: ${prescripcion.medicamento.toString()}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Stock sobrante del medicamento: ${prescripcion.getStockAnterior()}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Stock actual: ${prescripcion.stock}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  const SizedBox(height: 8.0),
                  if (prescripcion.medicamento.stockAnterior != 0) ...[
                    SizedBox(height: 16.0),
                    CheckboxListTile(
                      title: Text("¿Usar stock sobrante?"),
                      value: _stockAnterior == 1,
                      onChanged: (newValue) {
                        setState(() {
                          _stockAnterior = newValue! ? 1 : 0;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                  if (_stockAnterior == 0) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Seleccione el familiar que trajo el stock:"),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FutureBuilder<List<Familiar>?>(
                        future: _familiares,
                        builder: (BuildContext context, AsyncSnapshot<List<Familiar>?> snapshot) {
                          if (snapshot.hasData) {
                            List<Familiar> familiares = snapshot.data!;
                            return DropdownButton<Familiar>(
                              value: _selectedFamiliar,
                              items: [
                                DropdownMenuItem<Familiar>(
                                  value: null,
                                  child: Text("Seleccione un familiar"),
                                ),
                                ...familiares.map((familiar) {
                                  return DropdownMenuItem<Familiar>(
                                    value: familiar,
                                    child: Text(familiar.ci + ' - ' + familiar.nombre + " " + familiar.apellido),
                                  );
                                }),
                              ],
                              onChanged: (Familiar? newValue) {
                                setState(() {
                                  _selectedFamiliar = newValue;
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
                    ElevatedButton(
                      onPressed: () {
                        _selectedFamiliar = null;
                        Navigator.of(context).pop();
                        altaPopUp(prescripcion);
                      },
                      child: Text('Agregar Familiar'),
                    ),
                  ],
                  SizedBox(height: 10),
                  Form(
                    key: _formKey, // Agregar la key del formulario
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Ingrese la cantidad:',
                            hintText: 'Cantidad de medicamento',
                          ),
                          maxLength: 100,
                          controller: _fieldStock,
                          validator: (value) {
                            if (value == null || value.isEmpty || int.parse(value) == 0) {
                              // Reemplazar "value == 0" por "int.parse(value) == 0"
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
                            if (value == null || value.isEmpty || int.parse(value) == 0) {
                              // Reemplazar "value == 0" por "int.parse(value) == 0"
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
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            cargarStock();
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Registrar Stock'),
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
          );
        },
      ),
    );
  }
}
