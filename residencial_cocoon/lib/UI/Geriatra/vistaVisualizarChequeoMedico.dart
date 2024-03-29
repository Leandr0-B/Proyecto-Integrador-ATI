import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaVisualizarChequeoMedico.dart';
import 'package:residencial_cocoon/Dominio/Modelo/chequeoMedico.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisualizarChequeoMedico.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaVisualizarChequeoMedico extends StatefulWidget {
  VistaVisualizarChequeoMedico();

  @override
  _VistaVisualizarChequeoMedicoState createState() => _VistaVisualizarChequeoMedicoState();
}

//Get set

class _VistaVisualizarChequeoMedicoState extends State<VistaVisualizarChequeoMedico> implements IvistaVisualizarChequeoMedico {
  Future<List<ChequeoMedico>> _chequeosMedicos = Future.value([]);
  ControllerVistaVisualizarChequeoMedico _controller = ControllerVistaVisualizarChequeoMedico.empty();

  int _paginaActual = 1;
  int _elementosPorPagina = 5;
  Future<int> _cantidadDePaginas = Future.value(0);
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  String? _palabraClave;
  String? _ciResidente;

  DateTime? _fechaDesdeFiltro;
  DateTime? _fechaHastaFiltro;
  String? _palabraClaveFiltro;
  String? _ciResidenteFiltro;

  bool _filtroExpandido = false;
  Usuario? usuario = Fachada.getInstancia()?.getUsuario();

  final _palabraClaveController = TextEditingController();
  final _ciResidenteController = TextEditingController();

  Future<void> selectFechaDesde(BuildContext context) async {
    DateTime? picked = await Utilidades.selectFechaConTope(context, _fechaDesde);

    if (picked != null && picked != _fechaDesde) {
      setState(() {
        _fechaDesde = picked;
      });
    }
  }

  Future<void> selectFechaHasta(BuildContext context) async {
    DateTime? picked = await Utilidades.selectFechaConTope(context, _fechaHasta);

    if (picked != null && picked != _fechaHasta) {
      setState(() {
        _fechaHasta = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaVisualizarChequeoMedico(this);
    if (usuario!.esResidente() && !usuario!.esAdministrador()) {
      _ciResidenteFiltro = usuario?.ci;
    }
    obtenerChequeosMedicosPaginadosConfiltros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chequeos Médicos',
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
              Expanded(
                child: InkWell(
                  onTap: () => selectFechaDesde(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Fecha',
                    ),
                    child: Text(
                      _fechaDesde != null ? DateFormat('dd/MM/yyyy').format(_fechaDesde!) : 'Fecha Desde',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => selectFechaHasta(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Fecha',
                    ),
                    child: Text(
                      _fechaHasta != null ? DateFormat('dd/MM/yyyy').format(_fechaHasta!) : 'Fecha Hasta',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!usuario!.esResidente() || usuario!.esAdministrador()) ...[
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
              ],
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Palabra clave',
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
                  obtenerChequeosMedicosPaginadosBotonFiltrar();
                },
                child: const Text('Filtrar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    limpiarFiltros();
                    obtenerChequeosMedicosPaginados();
                  });
                },
                child: const Text('Mostrar Todos'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ChequeoMedico>>(
            future: _chequeosMedicos,
            builder: (BuildContext context, AsyncSnapshot<List<ChequeoMedico>> snapshot) {
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
                            'Aún no hay Chequeos Médicos',
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
                      ChequeoMedico chequeoMedico = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          mostrarPopUp(chequeoMedico);
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
                                      'Chequeo Médico, Residente: ${chequeoMedico.ciResidente()} - ${chequeoMedico.nombreResidente()} - ${chequeoMedico.apellidoResidente()}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Descripcion : ${chequeoMedico.descripcion}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    if (chequeoMedico.controles.isNotEmpty) ...[
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Controles: ${chequeoMedico.imprimirControlesMedicos()}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                    Text(
                                      'Fecha : ${chequeoMedico.imprimirFecha()}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Registrado por: ${chequeoMedico.ciGeriatra()} - ${chequeoMedico.nombreGeriatra()} - ${chequeoMedico.apellidoGeriatra()}',
                                      style: const TextStyle(fontSize: 14.0),
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
                                        obtenerChequeosMedicosPaginadosConfiltros();
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
                                        obtenerChequeosMedicosPaginadosConfiltros();
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
          InkWell(
            onTap: () => selectFechaDesde(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                hintText: 'Fecha',
              ),
              child: Text(
                _fechaDesde != null ? DateFormat('dd/MM/yyyy').format(_fechaDesde!) : 'Fecha Desde',
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => selectFechaHasta(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                hintText: 'Fecha',
              ),
              child: Text(
                _fechaHasta != null ? DateFormat('dd/MM/yyyy').format(_fechaHasta!) : 'Fecha Hasta',
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!usuario!.esResidente() || usuario!.esAdministrador()) ...[
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
            const SizedBox(height: 8),
          ],
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Palabra clave',
            ),
            controller: _palabraClaveController,
            onChanged: (value) {
              setState(() {
                _palabraClave = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerChequeosMedicosPaginadosBotonFiltrar();
                },
                child: const Text('Filtrar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    obtenerChequeosMedicosPaginados();
                  });
                },
                child: const Text('Mostrar Todos'),
              ),
            ],
          ),
        ],
        Expanded(
          child: FutureBuilder<List<ChequeoMedico>>(
            future: _chequeosMedicos,
            builder: (BuildContext context, AsyncSnapshot<List<ChequeoMedico>> snapshot) {
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
                            'Aún no hay Salidas Medicas',
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
                      ChequeoMedico chequeoMedico = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          mostrarPopUp(chequeoMedico);
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
                                      'Chequeo Médico, Residente: ${chequeoMedico.ciResidente()} - ${chequeoMedico.nombreResidente()} - ${chequeoMedico.apellidoResidente()}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Descripcion : ${chequeoMedico.descripcion}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    if (chequeoMedico.controles.isNotEmpty) ...[
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Controles: ${chequeoMedico.imprimirControlesMedicos()}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                    Text(
                                      'Fecha : ${chequeoMedico.imprimirFecha()}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Registrado por: ${chequeoMedico.ciGeriatra()} - ${chequeoMedico.nombreGeriatra()} - ${chequeoMedico.apellidoGeriatra()}',
                                      style: const TextStyle(fontSize: 14.0),
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
                                        obtenerChequeosMedicosPaginadosConfiltros();
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
                                        obtenerChequeosMedicosPaginadosConfiltros();
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
  void mostrarPopUp(ChequeoMedico chequeoMedico) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                'Chequeo Médico, Residente: ${chequeoMedico.ciResidente()} - ${chequeoMedico.nombreResidente()} - ${chequeoMedico.apellidoResidente()}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Descripcion : ${chequeoMedico.descripcion}',
                style: const TextStyle(fontSize: 16.0),
              ),
              if (chequeoMedico.controles.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  'Controles: ${chequeoMedico.imprimirControlesMedicos()}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
              Text(
                'Fecha : ${chequeoMedico.imprimirFecha()}',
                style: const TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Registrado por: ${chequeoMedico.ciGeriatra()} - ${chequeoMedico.nombreGeriatra()} - ${chequeoMedico.apellidoGeriatra()}',
                style: const TextStyle(fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
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
  void obtenerChequeosMedicosPaginadosBotonFiltrar() {
    _fechaDesdeFiltro = _fechaDesde;
    _fechaHastaFiltro = _fechaHasta;
    _palabraClaveFiltro = _palabraClave;
    _ciResidenteFiltro = _ciResidente;
    if (_fechaDesdeFiltro != null && _fechaHastaFiltro != null && _fechaDesdeFiltro!.isAfter(_fechaHastaFiltro!)) {
      mostrarMensajeError("La fecha desde no puede ser mayor a la fecha hasta.");
    } else if (_fechaDesdeFiltro == null && _fechaHastaFiltro != null || _fechaDesdeFiltro != null && _fechaHastaFiltro == null) {
      mostrarMensajeError("Debe seleccionar ambas fechas.");
    } else {
      _paginaActual = 1;
      obtenerChequeosMedicosPaginadosConfiltros();
    }
  }

  @override
  void obtenerChequeosMedicosPaginadosConfiltros() {
    _chequeosMedicos =
        _controller.obtenerChequeosMedicosPaginadosConFiltros(_paginaActual, _elementosPorPagina, _fechaDesdeFiltro, _fechaHastaFiltro, _ciResidenteFiltro, _palabraClaveFiltro);
    _cantidadDePaginas = _controller.calcularTotalPaginas(_elementosPorPagina, _fechaDesdeFiltro, _fechaHastaFiltro, _ciResidenteFiltro, _palabraClaveFiltro);
    setState(() {});
  }

  @override
  void obtenerChequeosMedicosPaginados() {
    limpiarFiltros();
    obtenerChequeosMedicosPaginadosConfiltros();
  }

  @override
  void limpiarFiltros() {
    _paginaActual = 1;
    _fechaDesde = null;
    _fechaHasta = null;
    _palabraClave = null;
    _palabraClaveController.clear();
    _fechaDesdeFiltro = null;
    _fechaHastaFiltro = null;
    _palabraClaveFiltro = null;
    _palabraClaveController.clear();
    if (usuario!.esResidente() && !usuario!.esAdministrador()) {
      _ciResidenteFiltro = usuario?.ci;
    } else {
      _ciResidenteFiltro = null;
      _ciResidenteController.clear();
    }
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }
}
