import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaRegistrarControlPeriodico.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/registroControlConPrescripcion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/UI/Chequeo/iVistaRegistrarControlPeriodico.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaRegistrarControlPeriodico extends StatefulWidget {
  @override
  State<VistaRegistrarControlPeriodico> createState() => _VistaRegistrarControlPeriodicoState();
}

class _VistaRegistrarControlPeriodicoState extends State<VistaRegistrarControlPeriodico> implements IvistaRegistrarControlPeriodico {
  ControllerVistaRegistrarControlPeriodico _controller = ControllerVistaRegistrarControlPeriodico.empty();
  Future<List<RegistroControlConPrescripcion>> _registros = Future.value([]);
  DateTime? _fechaFiltro;
  String? _ciFiltro;
  final _formKey = GlobalKey<FormState>();
  //RegistroControlConPrescripcion? _selectedRegistro;
  String _seleccionIcono = "";
  TimeOfDay? _horaPopUp;
  DateTime? _fechaPopUp;
  String _descripcionPopUp = '';
  List<Control> _controles = [];

  double _primerValor = 0;
  double _segundoValor = 0;
  final _formKeyControl = GlobalKey<FormState>();
  final _fieldPrimerValor = TextEditingController();
  final _fieldSegundoValor = TextEditingController();

  final _fieldDescripcion = TextEditingController();
  final _fieldHora = TextEditingController();
  final _fieldFecha = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaRegistrarControlPeriodico(this);
    obtenerRegistrosControlesConPrescripcion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de Controles Periódicos',
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
                  obtenerRegistrosControlesConPrescripcion();
                },
                child: const Text('Filtrar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<RegistroControlConPrescripcion>>(
            future: _registros,
            builder: (BuildContext context, AsyncSnapshot<List<RegistroControlConPrescripcion>> snapshot) {
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
                            'No hay controles periódicos para el día.',
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
                      RegistroControlConPrescripcion registro = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          _mostrarPopUp(registro);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: colorDelRegistro(registro),
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
                                child: Row(
                                  // Utilizamos un Row para colocar el texto y la imagen en una fila
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      // El Expanded se expandirá al 80% del ancho disponible
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Control Periódica, Residente: ${registro.ciResidente()} - ${registro.nombreResidente()} - ${registro.apellidoResidente()} ',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Descripcion : ${registro.descripcionPrescripcion()}',
                                            style: const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Fecha Pactada: ${DateFormat('dd/MM/yyyy').format(registro.fecha_pactada)}',
                                            style: const TextStyle(fontSize: 14.0),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Hora Pactada: ${registro.hora_pactada.hour.toString().padLeft(2, '0')}:${registro.hora_pactada.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(fontSize: 14.0),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Programado por: ${registro.ciGeriatra()} - ${registro.nombreGeriatra()} - ${registro.apellidoGeriatra()}',
                                            style: const TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 25.0),
                                      child: SizedBox(
                                        width: 0.2 * 300, // 20% del ancho total (300 en este caso)
                                        child: _seleccionIcono != ""
                                            ? Icon(
                                                _obtenerIcono(_seleccionIcono),
                                                size: 80, // Tamaño del ícono
                                                color: const Color.fromARGB(150, 0, 0, 0), // Color del ícono (puedes cambiarlo según tus necesidades)
                                              )
                                            : Container(),
                                      ),
                                    )
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
                  obtenerRegistrosControlesConPrescripcion();
                },
                child: const Text('Filtrar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<RegistroControlConPrescripcion>>(
            future: _registros,
            builder: (BuildContext context, AsyncSnapshot<List<RegistroControlConPrescripcion>> snapshot) {
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
                            'No hay controles periódicos para el día.',
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
                      RegistroControlConPrescripcion registro = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          _mostrarPopUp(registro);
                        },
                        child: SizedBox(
                          width: 300, // Ancho deseado para las tarjetas
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: colorDelRegistro(registro),
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
                                      'Control Periódica, Residente: ${registro.ciResidente()} - ${registro.nombreResidente()} - ${registro.apellidoResidente()} ',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Descripcion : ${registro.descripcionPrescripcion()}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Fecha Pactada: ${DateFormat('dd/MM/yyyy').format(registro.fecha_pactada)}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Hora Pactada: ${registro.hora_pactada.hour.toString().padLeft(2, '0')}:${registro.hora_pactada.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Programado por: ${registro.ciGeriatra()} - ${registro.nombreGeriatra()} - ${registro.apellidoGeriatra()}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 16.0),
                                    if (_seleccionIcono != "")
                                      Center(
                                        child: Icon(
                                          _obtenerIcono(_seleccionIcono),
                                          size: 80, // Tamaño del ícono
                                          color: Color.fromARGB(150, 0, 0, 0), // Color del ícono
                                        ),
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

  void obtenerRegistrosControlesConPrescripcion() {
    _registros = _controller.obtenerRegistrosControlesConPrescripcion(_fechaFiltro, _ciFiltro);
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

  IconData _obtenerIcono(String icono) {
    switch (icono) {
      case 'procesado':
        return Icons.check_circle_outline;
      case 'vencido':
        return Icons.watch_later_outlined;
      case 'enHora':
        return Icons.circle_notifications_outlined;
      case 'porVencer':
        return Icons.warning_amber_rounded;
      default:
        return Icons.live_help_rounded;
    }
  }

  Color colorDelRegistro(RegistroControlConPrescripcion registro) {
    if (registro.procesada == 1) {
      _seleccionIcono = "procesado";
      return const Color.fromARGB(150, 42, 119, 44);
    } else if (registro.fecha_pactada.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      _seleccionIcono = "vencido";
      return const Color.fromARGB(120, 145, 21, 12);
    } else {
      final currentTime = TimeOfDay.now();
      switch (_compareTimeOfDay(registro.hora_pactada, currentTime)) {
        case 0:
          _seleccionIcono = "enHora";
          return Colors.orange;
        case -1:
          _seleccionIcono = "vencido";
          return const Color.fromARGB(120, 145, 21, 12);
        case 1:
          if (_diferencia15Minutos(registro.hora_pactada, currentTime)) {
            _seleccionIcono = "porVencer";
            return const Color.fromARGB(150, 235, 214, 29);
          } else {
            _seleccionIcono = "";
            return Colors.white;
          }
        default:
          _seleccionIcono = "";
          return Colors.white;
      }
    }
  }

  @override
  void cambiarColor() {
    setState(() {});
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    _horaPopUp = null;
    _fechaPopUp = null;
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

  void _mostrarPopUp(RegistroControlConPrescripcion registro) {
    _horaPopUp = registro.hora_pactada;
    _fechaPopUp = registro.fecha_pactada;
    Control? _selectedControl;
    if (registro.procesada == 1) {
      _fieldDescripcion.text = registro.descripcion;
      _fieldHora.text = DateFormat('HH:mm').format(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          registro.hora_de_realizacion.hour,
          registro.hora_de_realizacion.minute,
        ),
      );
      _fieldFecha.text = DateFormat('dd/MM/yyyy').format(registro.fecha_realizada);
    } else {
      _controles = registro.controles();
      _selectedControl = null;
      _fieldDescripcion.text = registro.descripcion;
      _fieldHora.text = DateFormat('HH:mm').format(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          registro.hora_pactada.hour,
          registro.hora_pactada.minute,
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
                  'Control Periódico, Residente: ${registro.ciResidente()} - ${registro.nombreResidente()} - ${registro.apellidoResidente()}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Descripcion : ${registro.descripcionPrescripcion()}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Fecha Pactada: ${DateFormat('dd/MM/yyyy').format(registro.fecha_pactada)}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Hora pactada: ${DateFormat('HH:mm').format(
                    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, registro.hora_pactada.hour, registro.hora_pactada.minute),
                  )}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                if (registro.procesada == 1) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    'Controles:\n${registro.controles().map((control) => control.toStringProcesar()).join("\n")}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ] else ...[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Lista de controles"),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _controles.length,
                    itemBuilder: (context, index) {
                      final control = _controles[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Text('${control.nombre} ${control.unidad}'),
                            IconButton(
                              icon: Icon(Icons.arrow_circle_right_outlined),
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                  _valorControlPopUp(control, registro);

                                  setState(() {});
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Lista de valores"),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _controles.length,
                    itemBuilder: (context, index) {
                      final control = _controles[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Text('${control.nombre} ${control.unidad} ${control.valor_compuesto == 1 ? "${control.valor} - ${control.segundoValor}" : control.valor}'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
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
                      ElevatedButton(
                        child: Text("Procesar"),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            procesarControl(registro);
                            Navigator.pop(context);
                          }
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

  Future<void> procesarControl(RegistroControlConPrescripcion registro) async {
    registro.descripcion = _descripcionPopUp;
    registro.hora_de_realizacion = _horaPopUp;
    registro.fecha_realizada = _fechaPopUp;
    await _controller.procesarControl(registro);
  }

  void _valorControlPopUp(Control control, RegistroControlConPrescripcion registro) {
    _fieldPrimerValor.clear();
    _fieldSegundoValor.clear();
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
                    key: _formKeyControl,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16.0),
                          if (control.valor_compuesto == 1) ...[
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese primer valor:',
                                hintText: 'Valor del control',
                              ),
                              maxLength: 100,
                              controller: _fieldPrimerValor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _primerValor = double.parse(value!);
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese el segundo valor:',
                                hintText: 'Valor del control',
                              ),
                              maxLength: 100,
                              controller: _fieldSegundoValor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _segundoValor = double.parse(value!);
                              },
                            ),
                          ] else ...[
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ingrese el valor:',
                                hintText: 'Valor del control',
                              ),
                              maxLength: 100,
                              controller: _fieldPrimerValor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese el valor del control.';
                                }
                                if (num.tryParse(value) == null) {
                                  return 'Solo puede ingresar valores numéricos.';
                                }
                                if (num.tryParse(value)! <= 0) {
                                  return 'Solo puede ingresar valores positivos.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _primerValor = double.parse(value!);
                              },
                            ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKeyControl.currentState!.validate()) {
                                    _formKeyControl.currentState!.save();
                                    setState(() {
                                      if (control.valor_compuesto == 0) {
                                        control.valor = _primerValor;
                                      } else {
                                        control.valor = _primerValor;
                                        control.segundoValor = _segundoValor;
                                      }
                                    });
                                    Navigator.of(context).pop();
                                    _mostrarPopUp(registro);
                                    setState(() {});
                                  }
                                },
                                child: const Text('Guardar valores'),
                              ),
                              SizedBox(width: 8.0), // Ajusta la separación entre los botones según tus necesidades
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _mostrarPopUp(registro);
                                  setState(() {});
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
    ).then((_) {
      setState(() {});
    });
  }
}
