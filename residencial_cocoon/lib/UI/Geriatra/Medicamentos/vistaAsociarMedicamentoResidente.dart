import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaAsosiarMedicamentoResidente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/Medicamentos/iVistaAsociarMedicamentoResidente.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaPrescripcionMedicamento extends StatefulWidget {
  @override
  State<VistaPrescripcionMedicamento> createState() =>
      _VistaPrescripcionMedicamentoState();
}

class _VistaPrescripcionMedicamentoState
    extends State<VistaPrescripcionMedicamento>
    implements IvistaPrescripcionMedicamento {
  ControllerVistaPrescripcionMedicamento controller =
      ControllerVistaPrescripcionMedicamento.empty();
  final _formKey = GlobalKey<FormState>();
  Usuario? selectedResidente;
  Sucursal? selectedSucursal;
  Medicamento? selectedMedicamento;
  bool residentesVisible = false;
  final fieldMedicamento = TextEditingController();
  int _paginaActual = 1;
  Future<List<Medicamento>?> medicamentos = Future.value([]);
  Future<int> _cantidadDePaginas = Future.value(0);

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaPrescripcionMedicamento(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prescripcion de medicamento',
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
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Sucursal>?> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: snapshot.data!.map((sucursal) {
                          return RadioListTile<Sucursal>(
                            title: Text(sucursal.nombre),
                            value: sucursal,
                            groupValue: selectedSucursal,
                            onChanged: (Sucursal? newValue) {
                              setState(() {
                                selectedSucursal = newValue;
                                selectedResidente = null;
                                residentesVisible = true;
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
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Usuario>?> snapshot) {
                            if (snapshot.hasData) {
                              List<Usuario> residentes = snapshot.data!;
                              return DropdownButton<Usuario>(
                                value: selectedResidente,
                                items: [
                                  DropdownMenuItem<Usuario>(
                                    value: null,
                                    child: Text("Seleccione un residente"),
                                  ),
                                  ...residentes.map((residente) {
                                    return DropdownMenuItem<Usuario>(
                                      value: residente,
                                      child: Text(residente.nombre +
                                          ' | ' +
                                          residente.ci),
                                    );
                                  }),
                                ],
                                onChanged: (Usuario? newValue) {
                                  setState(() {
                                    selectedResidente = newValue;
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
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Medicamentos Seleccionado:"),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(selectedMedicamento?.toString() ?? ''),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          selectedMedicamento = null;
                          mostrarPopUp(controller.listaMedicamentos());
                        },
                        child: Text('Seleccionar medicamento'),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      asosiarMedicamento();
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
  Future<void> asosiarMedicamento() {
    // TODO: implement asosiarMedicamento
    throw UnimplementedError();
  }

  @override
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  @override
  void limpiar() {
    // TODO: implement limpiar
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
    return await controller.listaResidentes(selectedSucursal);
  }

  @override
  Future<List<Sucursal>?> listaSucursales() async {
    return await controller.listaSucursales();
  }

  @override
  Future<List<Medicamento>?> listaMedicamentos() async {
    return await controller.listaMedicamentos();
  }

  void obtenerMedicamentosConFiltro() {
    medicamentos = controller.listaMedicamentos();
    _cantidadDePaginas = controller.cantidadPaginas();
    setState(() {});
  }

  void mostrarPopUp(Future<List<Medicamento>?> elementos) {
    final TextEditingController textFieldController = TextEditingController();

    elementos.then((lista) {
      showDialog(
        context: context,
        builder: (context) {
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
                        child: Text('Buscar medicamento:'),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: textFieldController,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          final inputText = textFieldController.text;
                          // otraFuncion(inputText);
                        },
                        child: Text('Buscar'),
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
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: lista?.length ?? 0,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 8.0),
                    itemBuilder: (BuildContext context, int index) {
                      final elemento = lista![index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMedicamento = elemento;
                          });
                          Navigator.of(context).pop(); // Cerrar el diálogo
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
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      );
                    },
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
                        future: _cantidadDePaginas,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                                ''); // Muestra un mensaje de error si hay un problema al obtener _cantidadDePaginas
                          } else {
                            final int totalPagesValue = snapshot.data ??
                                0; // Obtiene el valor de _cantidadDePaginas
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
                                                  //obtenerSalidasMedicasPaginadasConfiltros();
                                                });
                                              },
                                      ),
                                      Text('$_paginaActual/$totalPagesValue'),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_forward),
                                        onPressed:
                                            _paginaActual == totalPagesValue
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _paginaActual++;
                                                      //obtenerSalidasMedicasPaginadasConfiltros();
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
              ),
            ),
          );
        },
      );
    });
  }
}
