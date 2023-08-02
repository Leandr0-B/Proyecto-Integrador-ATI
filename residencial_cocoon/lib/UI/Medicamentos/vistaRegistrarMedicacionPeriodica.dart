import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaVisualizarMedicacionPeriodica.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/registroMedicacionConPrescripcion.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaRegistrarMedicacionPeriodica.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaRegistrarMedicacionPeriodica extends StatefulWidget {
  @override
  State<VistaRegistrarMedicacionPeriodica> createState() => _VistaVisualizarMedicacionPeriodicaState();
}

class _VistaVisualizarMedicacionPeriodicaState extends State<VistaRegistrarMedicacionPeriodica> implements IvistaRegistrarMedicacionPeriodica {
  ControllerVistaRegistrarMedicacionPeriodica _controller = ControllerVistaRegistrarMedicacionPeriodica.empty();
  Future<List<RegistroMedicacionConPrescripcion>> _registros = Future.value([]);
  DateTime? _fechaFiltro;
  String? _ciFiltro;
  final _formKey = GlobalKey<FormState>();
  final _fieldDescripcion = TextEditingController();
  String _descripcionPopUp = '';
  final _fieldCantidad = TextEditingController();
  final _fieldHora = TextEditingController();
  final _fieldFecha = TextEditingController();
  int _cantidadPopUp = 0;
  TimeOfDay? _horaPopUp;
  DateTime? _fechaPopUp;
  RegistroMedicacionConPrescripcion? _selectedRegistro;

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaRegistrarMedicacionPeriodica(this);
    obtenerRegistrosMedicamentosConPrescripcion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de Medicación Periódica',
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
                  onTap: () => _selectFecha(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Fecha',
                    ),
                    child: Text(
                      _fechaFiltro != null ? DateFormat('dd/MM/yyyy').format(_fechaFiltro!) : 'Fecha',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Ci Residente',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _ciFiltro = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerRegistrosMedicamentosConPrescripcion();
                },
                child: const Text('Filtrar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<RegistroMedicacionConPrescripcion>>(
            future: _registros,
            builder: (BuildContext context, AsyncSnapshot<List<RegistroMedicacionConPrescripcion>> snapshot) {
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
                            'No hay medicaciones periodicas para el día.',
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
                      RegistroMedicacionConPrescripcion registro = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          _mostrarPopUp(registro);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: registro.procesada == 1
                                  ? Colors.green
                                  : registro.fecha_pactada.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                      ? Colors.red
                                      : (() {
                                          final currentTime = TimeOfDay.now();
                                          switch (_compareTimeOfDay(registro.horaPactada, currentTime)) {
                                            case 0:
                                              return Colors.orange;
                                            case -1:
                                              return Colors.red;
                                            case 1:
                                              if (_diferencia15Minutos(registro.horaPactada, currentTime)) {
                                                return Colors.yellow;
                                              } else {
                                                return Colors.white;
                                              }
                                          }
                                        })(),
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
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Medicacion Periódica, Residente: ${registro.prescripcion.ciResidente()} - ${registro.prescripcion.nombreResidente()} - ${registro.prescripcion.apellidoResidente()} ',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Descripcion : ${registro.prescripcion.descripcion}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Medicamento : ${registro.prescripcion.medicamento.nombre}- Cantidad: ${registro.prescripcion.cantidad} - Unidad: ${registro.prescripcion.medicamento.unidad}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Fecha Pactada: ${DateFormat('dd/MM/yyyy').format(registro.fecha_pactada)}',
                                        style: const TextStyle(fontSize: 14.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Hora Pactada: ${registro.horaPactada.hour.toString().padLeft(2, '0')}:${registro.horaPactada.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 14.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Programado por: ${registro.prescripcion.ciGeriatra()} - ${registro.prescripcion.nombreGeriatra()} - ${registro.prescripcion.apellidoGeriatra()}',
                                        style: const TextStyle(fontSize: 14.0),
                                      ),
                                    ],
                                  ),
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
      ],
    );
  }

  Widget buildNarrowLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectFecha(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Fecha',
                    ),
                    child: Text(
                      _fechaFiltro != null ? DateFormat('dd/MM/yyyy').format(_fechaFiltro!) : 'Fecha',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Ci Residente',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _ciFiltro = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerRegistrosMedicamentosConPrescripcion();
                },
                child: const Text('Filtrar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<RegistroMedicacionConPrescripcion>>(
            future: _registros,
            builder: (BuildContext context, AsyncSnapshot<List<RegistroMedicacionConPrescripcion>> snapshot) {
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
                            'No hay medicaciones periodicas para el día.',
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
                      RegistroMedicacionConPrescripcion registro = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          _mostrarPopUp(registro);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: registro.procesada == 1
                                  ? Colors.green
                                  : registro.fecha_pactada.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                      ? Colors.red
                                      : (() {
                                          final currentTime = TimeOfDay.now();
                                          switch (_compareTimeOfDay(registro.horaPactada, currentTime)) {
                                            case 0:
                                              return Colors.orange;
                                            case -1:
                                              return Colors.red;
                                            case 1:
                                              if (_diferencia15Minutos(registro.horaPactada, currentTime)) {
                                                return Colors.yellow;
                                              } else {
                                                return Colors.white;
                                              }
                                          }
                                        })(),
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
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Medicacion Periódica, Residente: ${registro.prescripcion.ciResidente()} - ${registro.prescripcion.nombreResidente()} - ${registro.prescripcion.apellidoResidente()} ',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Descripcion : ${registro.prescripcion.descripcion}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Medicamento : ${registro.prescripcion.medicamento.nombre}- Cantidad: ${registro.prescripcion.cantidad} - Unidad: ${registro.prescripcion.medicamento.unidad}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Fecha Pactada: ${DateFormat('dd/MM/yyyy').format(registro.fecha_pactada)}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Hora Pactada: ${registro.horaPactada.hour.toString().padLeft(2, '0')}:${registro.horaPactada.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Programado por: ${registro.prescripcion.ciGeriatra()} - ${registro.prescripcion.nombreGeriatra()} - ${registro.prescripcion.apellidoGeriatra()}',
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
      ],
    );
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    _horaPopUp = null;
    _fechaPopUp = null;
    _fieldCantidad.clear();
    _fieldDescripcion.clear();
    _fieldHora.clear();
    _fieldFecha.clear();
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

  void obtenerRegistrosMedicamentosConPrescripcion() {
    _registros = _controller.obtenerRegistrosMedicamentosConPrescripcion(_fechaFiltro, _ciFiltro);
    setState(() {});
  }

  Future<void> _selectFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFiltro ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _fechaFiltro) {
      setState(() {
        _fechaFiltro = picked;
      });
    }
  }

  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) {
      return -1;
    } else if (time1.hour > time2.hour) {
      return 1;
    } else {
      // Las horas son iguales, comparar los minutos
      if (time1.minute < time2.minute) {
        return -1;
      } else if (time1.minute > time2.minute) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  bool _diferencia15Minutos(TimeOfDay time1, TimeOfDay time2) {
    int minutes1 = time1.hour * 60 + time1.minute;
    int minutes2 = time2.hour * 60 + time2.minute;

    int diferencia = (minutes1 - minutes2).abs();

    return diferencia <= 15;
  }

  Future<void> _selectHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaPopUp ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _horaPopUp) {
      setState(() {
        _horaPopUp = picked;
        _fieldHora.text = DateFormat('HH:mm').format(
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, _horaPopUp!.hour, _horaPopUp!.minute),
        );
      });
    }
  }

  Future<void> _selectFechaPopup(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaPopUp ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _fechaPopUp) {
      setState(() {
        _fechaPopUp = picked;
        _fieldFecha.text = DateFormat('dd/MM/yyyy').format(_fechaPopUp!);
      });
    }
  }

  @override
  void cambiarColor(RegistroMedicacionConPrescripcion? unRegistro) {
    unRegistro?.procesada = 1;
    setState(() {});
  }

  void _mostrarPopUp(RegistroMedicacionConPrescripcion registro) {
    _selectedRegistro = registro;
    _horaPopUp = registro.horaPactada;
    _fechaPopUp = registro.fecha_pactada;

    if (registro.procesada == 1) {
      _fieldDescripcion.text = registro.descripcion;
      _fieldCantidad.text = registro.cantidadDada.toString();
      _fieldHora.text = DateFormat('HH:mm').format(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          registro.horaDeRealizacion.hour,
          registro.horaDeRealizacion.minute,
        ),
      );
      _fieldFecha.text = DateFormat('dd/MM/yyyy').format(registro.fecha_de_realizacion);
    } else {
      _fieldDescripcion.text = registro.descripcion;
      _fieldCantidad.text = registro.cantidadSugerida.toString();
      _fieldHora.text = DateFormat('HH:mm').format(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          registro.horaPactada.hour,
          registro.horaPactada.minute,
        ),
      );
      _fieldFecha.text = DateFormat('dd/MM/yyyy').format(registro.fecha_pactada);
    }
    setState(() {});
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // Ancho máximo deseado
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Medicacion Periódica, Residente: ${registro.prescripcion.ciResidente()} - ${registro.prescripcion.nombreResidente()} - ${registro.prescripcion.apellidoResidente()}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Descripcion : ${registro.prescripcion.descripcion}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Fecha Pactada: ${DateFormat('dd/MM/yyyy').format(registro.fecha_pactada)}',
                  style: const TextStyle(fontSize: 14.0),
                ),
                Text(
                  'Hora pactada: ${DateFormat('HH:mm').format(
                    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, registro.horaPactada.hour, registro.horaPactada.minute),
                  )}',
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Stock actual del medicamento: ${registro.prescripcion.medicamento.stock < registro.cantidadSugerida ? "No hay stock suficiente" : registro.prescripcion.medicamento.stock}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: registro.prescripcion.medicamento.stock < registro.cantidadSugerida ? Colors.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Ingrese una descripción (si es necesario):"),
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
                      _descripcionPopUp = value;
                    },
                    decoration: InputDecoration(
                      hintText: registro.procesada != 1 ? 'Descripción' : '',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      border: InputBorder.none, // Elimina el borde predeterminado del TextFormField
                    ),
                    enabled: registro.procesada != 1, // Habilita o deshabilita la edición según el estado de procesada
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Ingrese la cantidad administrada (0 si no se dio)',
                    hintText: 'Cantidad administrada al residente',
                  ),
                  maxLength: 100,
                  controller: _fieldCantidad,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la cantidad administrada del medicamento.';
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
                    _cantidadPopUp = int.parse(value!);
                  },
                  enabled: registro.procesada != 1, // Habilita o deshabilita la edición según el estado de procesada
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Fecha Realizacion',
                    hintText: 'Fecha',
                  ),
                  controller: _fieldFecha,
                  onTap: registro.procesada != 1 ? () => _selectFechaPopup(context) : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione una Fecha.';
                    }
                  },
                  readOnly: true, // Deshabilita la edición directa del campo de texto
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Hora Realizacion',
                    hintText: 'Hora',
                  ),
                  controller: _fieldHora,
                  onTap: registro.procesada != 1 ? () => _selectHora(context) : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione una hora.';
                    }
                  },
                  readOnly: true, // Deshabilita la edición directa del campo de texto
                ),
                SizedBox(height: 10),
                if (registro.procesada != 1) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                    children: [
                      if (registro.prescripcion.medicamento.stock >= registro.cantidadSugerida)
                        ElevatedButton(
                          child: Text("Procesar"),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              procesarMedicacion();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      SizedBox(width: 8.0),
                      if (registro.prescripcion.medicamento.stock < registro.cantidadSugerida)
                        ElevatedButton(
                          child: Text("Solicitar Stock"),
                          onPressed: () {
                            Navigator.pop(context);
                            _popUpConfirmacion(registro);
                          },
                        ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _popUpConfirmacion(RegistroMedicacionConPrescripcion registro) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // Ancho máximo deseado
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(
                '¿Estas seguro que quieres solicitar mas stock de la medicacion: ${registro.prescripcion.medicamento.nombre} para el residente: ${registro.prescripcion.nombreResidente()} ${registro.prescripcion.apellidoResidente()}?',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                children: [
                  ElevatedButton(
                    child: Text("Si"),
                    onPressed: () {
                      notificarStock(registro);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> notificarStock(RegistroMedicacionConPrescripcion registro) async {
    await _controller.notificarStock(registro);
  }

  Future<void> procesarMedicacion() async {
    _selectedRegistro?.cantidadDada = _cantidadPopUp;
    _selectedRegistro?.horaDeRealizacion = _horaPopUp!;
    _selectedRegistro?.fecha_de_realizacion = _fechaPopUp!;
    _selectedRegistro?.descripcion = _descripcionPopUp;
    await _controller.procesarMedicacion(_selectedRegistro);
  }
}
