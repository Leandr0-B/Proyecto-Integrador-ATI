import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaNotificacion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Inicio/vistaInicio.dart';
import 'package:residencial_cocoon/UI/Notificacion/iVistaNotificacion.dart';
import 'dart:html' as html;

class VistaNotificacion extends StatefulWidget {
  NotificacionActualizadaCallback _callback = NotificacionActualizadaCallback();

  VistaNotificacion(this._callback);

  @override
  _VistaNotificacionState createState() => _VistaNotificacionState();
}

//Get set

class _VistaNotificacionState extends State<VistaNotificacion>
    with WidgetsBindingObserver
    implements IVistaNotificacion {
  Future<List<Notificacion>> _notificaciones = Future.value([]);
  ControllerVistaNotificacion _controller = ControllerVistaNotificacion.empty();
  bool _isPageVisible = true;
  int currentPage = 1;
  int itemsPerPage = 5;
  int totalPages = 0;
  DateTime? fromDate;
  DateTime? toDate;
  String? keyword;
  bool onlyUnread = false;
  bool showFilters = false;
  bool _isExpanded = false;

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaNotificacion(this);
    obtenerNotificacionesPaginadas();
    _controller.escucharNotificacionEnPrimerPlano();

    WidgetsBinding.instance?.addObserver(this);
    html.document.onVisibilityChange.listen((event) {
      setState(() {
        _isPageVisible = _isPageVisible =
            html.document.hidden != null ? !html.document.hidden! : true;
      });
      if (_isPageVisible) {
        obtenerNotificacionesPaginadas();
      } else {}
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // La página se ha mostrado nuevamente
      setState(() {
        _isPageVisible = true;
      });
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      setState(() {
        _isPageVisible = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void obtenerUltimasNotificaciones() {
    _notificaciones = _controller.obtenerUltimasNotificaciones();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
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
                  onTap: () => selectFromDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Fecha',
                    ),
                    child: Text(
                      fromDate != null
                          ? DateFormat('dd/MM/yyyy').format(fromDate!)
                          : 'Fecha Desde',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => selectToDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Fecha',
                    ),
                    child: Text(
                      toDate != null
                          ? DateFormat('dd/MM/yyyy').format(toDate!)
                          : 'Fecha Hasta',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Palabra clave',
                  ),
                  onChanged: (value) {
                    setState(() {
                      keyword = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerNotificacionesPaginadas();
                },
                child: Text('Filtrar'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    obtenerNotificacionesPaginadas();
                  });
                },
                child: Text('Mostrar Todas'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Notificacion>>(
            future: _notificaciones,
            builder: (BuildContext context,
                AsyncSnapshot<List<Notificacion>> snapshot) {
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
                            'Aún no hay notificaciones',
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
                          height: 16.0); // Espacio entre cada notificación
                    },
                    itemBuilder: (BuildContext context, int index) {
                      Notificacion notificacion = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          marcarNotificacionComoLeida(notificacion);
                          mostrarPopUp(notificacion);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: notificacion.leida
                                  ? const Color.fromARGB(166, 201, 200, 200)
                                  : const Color.fromARGB(255, 255, 255, 255),
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
                                      notificacion.titulo,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      notificacion.leida ? 'Leída' : 'Nueva!',
                                      style: TextStyle(
                                        color: notificacion.leida
                                            ? Colors.black
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Enviado por: ${notificacion.nombreUsuarioQueEnvia()}',
                                      style: TextStyle(fontSize: 12.0),
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
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: currentPage == 1
                  ? null
                  : () {
                      setState(() {
                        currentPage--;
                        obtenerNotificacionesPaginadas();
                      });
                    },
            ),
            Text('$currentPage/$totalPages'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: currentPage == totalPages
                  ? null
                  : () {
                      setState(() {
                        currentPage++;
                        obtenerNotificacionesPaginadas();
                      });
                    },
            ),
          ],
        ),
      ],
    );
  }

  // Widget buildNarrowLayout() {
  //   return Column(
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           children: [
  //             InkWell(
  //               onTap: () => selectFromDate(context),
  //               child: InputDecorator(
  //                 decoration: InputDecoration(
  //                   hintText: 'Fecha',
  //                 ),
  //                 child: Text(
  //                   fromDate != null
  //                       ? DateFormat('dd/MM/yyyy').format(fromDate!)
  //                       : 'Fecha Desde',
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //             InkWell(
  //               onTap: () => selectToDate(context),
  //               child: InputDecorator(
  //                 decoration: InputDecoration(
  //                   hintText: 'Fecha',
  //                 ),
  //                 child: Text(
  //                   toDate != null
  //                       ? DateFormat('dd/MM/yyyy').format(toDate!)
  //                       : 'Fecha Hasta',
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //             TextFormField(
  //               decoration: InputDecoration(
  //                 labelText: 'Palabra clave',
  //               ),
  //               onChanged: (value) {
  //                 setState(() {
  //                   keyword = value;
  //                 });
  //               },
  //             ),
  //             SizedBox(height: 8),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     // Filtrar notificaciones
  //                     obtenerNotificacionesPaginadas();
  //                   },
  //                   child: Text('Filtrar'),
  //                 ),
  //                 SizedBox(width: 8),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       obtenerNotificacionesPaginadas();
  //                     });
  //                   },
  //                   child: Text('Mostrar Todas'),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 16),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       showFilters = !showFilters;
  //                     });
  //                   },
  //                   child: Text(
  //                       showFilters ? 'Ocultar Filtros' : 'Mostrar Filtros'),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //       Expanded(
  //         child: FutureBuilder<List<Notificacion>>(
  //           future: _notificaciones,
  //           builder: (BuildContext context,
  //               AsyncSnapshot<List<Notificacion>> snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return const Center(child: CircularProgressIndicator());
  //             } else if (snapshot.hasError) {
  //               return Text('Error: ${snapshot.error}');
  //             } else {
  //               if (snapshot.data!.isEmpty) {
  //                 return const Center(
  //                   child: Padding(
  //                     padding: EdgeInsets.only(top: 32.0),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Text(
  //                           'Aún no hay notificaciones',
  //                           style: TextStyle(fontSize: 16.0),
  //                         ),
  //                         SizedBox(height: 8.0),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               } else {
  //                 return ListView.separated(
  //                   padding: const EdgeInsets.all(16.0),
  //                   itemCount: snapshot.data!.length,
  //                   separatorBuilder: (BuildContext context, int index) {
  //                     return const SizedBox(
  //                         height: 16.0); // Espacio entre cada notificación
  //                   },
  //                   itemBuilder: (BuildContext context, int index) {
  //                     Notificacion notificacion = snapshot.data![index];
  //                     return GestureDetector(
  //                       onTap: () {
  //                         marcarNotificacionComoLeida(notificacion);
  //                         mostrarPopUp(notificacion);
  //                       },
  //                       child: SizedBox(
  //                         width: 300, // Ancho deseado para las tarjetas
  //                         child: Container(
  //                           width: double.infinity,
  //                           child: Card(
  //                             color: notificacion.leida
  //                                 ? const Color.fromARGB(166, 201, 200, 200)
  //                                 : const Color.fromARGB(255, 255, 255, 255),
  //                             shape: RoundedRectangleBorder(
  //                               // Borde más fuerte y ancho
  //                               borderRadius: BorderRadius.circular(8.0),
  //                               side: const BorderSide(
  //                                 color: Colors.black,
  //                                 width: 0.25,
  //                               ),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(20.0),
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     notificacion.titulo,
  //                                     style: TextStyle(
  //                                       fontSize: 16.0,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 8.0),
  //                                   Text(
  //                                     notificacion.leida ? 'Leída' : 'Nueva!',
  //                                     style: TextStyle(
  //                                       color: notificacion.leida
  //                                           ? Colors.black
  //                                           : Colors.red,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 8.0),
  //                                   Text(
  //                                     'Enviado por: ${notificacion.nombreUsuarioQueEnvia()}',
  //                                     style: TextStyle(fontSize: 12.0),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 );
  //               }
  //             }
  //           },
  //         ),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           IconButton(
  //             icon: Icon(Icons.arrow_back),
  //             onPressed: currentPage == 1
  //                 ? null
  //                 : () {
  //                     setState(() {
  //                       currentPage--;
  //                       obtenerNotificacionesPaginadas();
  //                     });
  //                   },
  //           ),
  //           Text('$currentPage/$totalPages'),
  //           IconButton(
  //             icon: Icon(Icons.arrow_forward),
  //             onPressed: currentPage == totalPages
  //                 ? null
  //                 : () {
  //                     setState(() {
  //                       currentPage++;
  //                       obtenerNotificacionesPaginadas();
  //                     });
  //                   },
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget buildNarrowLayout() {
    return Column(
      children: [
        ListTile(
          title: Text('Filtros'),
          trailing: _isExpanded
              ? Icon(Icons.keyboard_arrow_up)
              : Icon(Icons.keyboard_arrow_down),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        if (_isExpanded) ...[
          InkWell(
            onTap: () => selectFromDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: 'Fecha',
              ),
              child: Text(
                fromDate != null
                    ? DateFormat('dd/MM/yyyy').format(fromDate!)
                    : 'Fecha Desde',
              ),
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => selectToDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: 'Fecha',
              ),
              child: Text(
                toDate != null
                    ? DateFormat('dd/MM/yyyy').format(toDate!)
                    : 'Fecha Hasta',
              ),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Palabra clave',
            ),
            onChanged: (value) {
              setState(() {
                keyword = value;
              });
            },
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerNotificacionesPaginadas();
                },
                child: Text('Filtrar'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    obtenerNotificacionesPaginadas();
                  });
                },
                child: Text('Mostrar Todas'),
              ),
            ],
          ),
        ],
        Expanded(
          child: FutureBuilder<List<Notificacion>>(
            future: _notificaciones,
            builder: (BuildContext context,
                AsyncSnapshot<List<Notificacion>> snapshot) {
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
                            'Aún no hay notificaciones',
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
                      Notificacion notificacion = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          marcarNotificacionComoLeida(notificacion);
                          mostrarPopUp(notificacion);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: notificacion.leida
                                  ? const Color.fromARGB(166, 201, 200, 200)
                                  : const Color.fromARGB(255, 255, 255, 255),
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
                                      notificacion.titulo,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      notificacion.leida ? 'Leída' : 'Nueva!',
                                      style: TextStyle(
                                        color: notificacion.leida
                                            ? Colors.black
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Enviado por: ${notificacion.nombreUsuarioQueEnvia()}',
                                      style: TextStyle(fontSize: 12.0),
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
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: currentPage == 1
                  ? null
                  : () {
                      setState(() {
                        currentPage--;
                        obtenerNotificacionesPaginadas();
                      });
                    },
            ),
            Text('$currentPage/$totalPages'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: currentPage == totalPages
                  ? null
                  : () {
                      setState(() {
                        currentPage++;
                        obtenerNotificacionesPaginadas();
                      });
                    },
            ),
          ],
        ),
      ],
    );
  }

  void mostrarPopUp(Notificacion notificacion) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width:
              MediaQuery.of(context).size.width * 0.8, // Ancho máximo deseado
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notificacion.titulo,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                notificacion.mensaje,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Enviado por: ${notificacion.nombreUsuarioQueEnvia()}',
                style: TextStyle(fontSize: 14.0),
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void marcarNotificacionComoLeida(notificacion) {
    widget._callback.notificacionActualizada(notificacion);
    setState(() {
      _controller.marcarNotificacionComoLeida(notificacion);
    });
  }

  void obtenerNotificacionesPaginadas() {
    _notificaciones =
        _controller.obtenerNotificacionesPaginadas(currentPage, itemsPerPage);
    totalPages = _controller.calcularTotalPaginas(itemsPerPage);
    setState(() {});
  }
}
