import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaListaUsuario.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaListaUsuario.dart';
import 'package:residencial_cocoon/Utilidades/utilidades.dart';

class VistaListaUsuario extends StatefulWidget {
  @override
  _VistaListaUsuarioState createState() => _VistaListaUsuarioState();
}

class _VistaListaUsuarioState extends State<VistaListaUsuario> implements IvistaListaUsuario {
  int _paginaActual = 1;
  int _elementosPorPagina = 5;
  Future<int> _cantidadDePaginas = Future.value(0);
  Future<List<Usuario>> _usuarios = Future.value([]);
  ControllerVistaListaUsuario _controller = ControllerVistaListaUsuario.empty();
  String? _palabraClaveNombre;
  String? _palabraClaveApellido;
  String? _ciResidente;
  bool _filtroExpandido = false;

  final _palabraClaveNombreController = TextEditingController();
  final _palabraClaveApellidoController = TextEditingController();
  final _ciResidenteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaListaUsuario(this);
    obtenerUsuariosPaginadosConfiltros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Usuarios',
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
                    labelText: 'Documento Identificador',
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
                    labelText: 'Nombre',
                  ),
                  controller: _palabraClaveNombreController,
                  onChanged: (value) {
                    setState(() {
                      _palabraClaveNombre = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                  ),
                  controller: _palabraClaveApellidoController,
                  onChanged: (value) {
                    setState(() {
                      _palabraClaveApellido = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Filtrar notificaciones
                  obtenerUsuariosPaginadosBotonFiltrar();
                },
                child: const Text('Filtrar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    limpiarFiltros();
                    obtenerUsuariosPaginados();
                  });
                },
                child: const Text('Mostrar Todos'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Usuario>>(
            future: _usuarios,
            builder: (BuildContext context, AsyncSnapshot<List<Usuario>> snapshot) {
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
                            'Aún no hay usuarios registrados',
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
                      Usuario usuario = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          mostrarPopUp(usuario);
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
                                      'Usuario, Nombre: ${usuario.nombre} - Apellido: ${usuario.apellido} - Documento: ${usuario.ci}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Edad: ${usuario.mostrarEdad()}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    if (usuario.esAdministrador())
                                      Text(
                                        'Usuario Administrador',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    const SizedBox(height: 8.0),
                                    if (usuario.esResidente() && !usuario.getfamiliares()!.isEmpty) ...[
                                      Text(
                                        'Telefono Familiar: ${usuario.telefonoFamiliar()}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Familiares: ${usuario.getfamiliares()?.map((familiar) => familiar.toStringMostrar()).join(", ")},',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ] else ...[
                                      Text(
                                        'Telefono: ${usuario.telefono}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Email: ${usuario.email}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Roles: ${usuario.roles?.map((rol) => rol.toStringMostrar()).join(", ")}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Sucursales: ${usuario.getSucursales()?.map((sucursal) => sucursal.toStringMostrar()).join(", ")}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
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
                                        obtenerUsuariosPaginadosConfiltros();
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
                                        obtenerUsuariosPaginadosConfiltros();
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
              labelText: 'Documento Identificador',
            ),
            controller: _ciResidenteController,
            onChanged: (value) {
              setState(() {
                _ciResidente = value;
              });
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Nombre',
            ),
            controller: _palabraClaveNombreController,
            onChanged: (value) {
              setState(() {
                _palabraClaveNombre = value;
              });
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Apellido',
            ),
            controller: _palabraClaveApellidoController,
            onChanged: (value) {
              setState(() {
                _palabraClaveApellido = value;
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
                  obtenerUsuariosPaginadosBotonFiltrar();
                },
                child: const Text('Filtrar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    obtenerUsuariosPaginados();
                  });
                },
                child: const Text('Mostrar Todos'),
              ),
            ],
          ),
        ],
        Expanded(
          child: FutureBuilder<List<Usuario>>(
            future: _usuarios,
            builder: (BuildContext context, AsyncSnapshot<List<Usuario>> snapshot) {
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
                            'Aún no hay usuarios registrados',
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
                      Usuario usuario = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          mostrarPopUp(usuario);
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
                                      'Usuario, Nombre: ${usuario.nombre} - Apellido: ${usuario.apellido} - Documento: ${usuario.ci}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Edad: ${usuario.mostrarEdad()}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    if (usuario.esAdministrador())
                                      Text(
                                        'Usuario Administrador',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    const SizedBox(height: 8.0),
                                    if (usuario.esResidente() && !usuario.getfamiliares()!.isEmpty) ...[
                                      Text(
                                        'Telefono Familiar: ${usuario.telefonoFamiliar()}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Familiares: ${usuario.getfamiliares()?.map((familiar) => familiar.toStringMostrar()).join(", ")},',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ] else ...[
                                      Text(
                                        'Telefono: ${usuario.telefono}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Email: ${usuario.email}',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Roles: ${usuario.roles?.map((rol) => rol.toStringMostrar()).join(", ")}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Sucursales: ${usuario.getSucursales()?.map((sucursal) => sucursal.toStringMostrar()).join(", ")}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 8.0),
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
                                        obtenerUsuariosPaginadosConfiltros();
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
                                        obtenerUsuariosPaginadosConfiltros();
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

  void mostrarPopUp(Usuario usuario) {
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
                'Usuario, Nombre: ${usuario.nombre} - Apellido: ${usuario.apellido} - Documento: ${usuario.ci}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Edad: ${usuario.mostrarEdad()}',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              if (usuario.esAdministrador())
                Text(
                  'Usuario Administrador',
                  style: const TextStyle(fontSize: 16.0),
                ),
              const SizedBox(height: 8.0),
              if (usuario.esResidente() && !usuario.getfamiliares()!.isEmpty) ...[
                Text(
                  'Telefono Familiar: ${usuario.telefonoFamiliar()}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Familiares: ${usuario.getfamiliares()?.map((familiar) => familiar.toStringMostrar()).join(", ")},',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
              ] else ...[
                Text(
                  'Telefono: ${usuario.telefono}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Email: ${usuario.email}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
              const SizedBox(height: 8.0),
              Text(
                'Roles: ${usuario.roles?.map((rol) => rol.toStringMostrar()).join(", ")}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Sucursales: ${usuario.getSucursales()?.map((sucursal) => sucursal.toStringMostrar()).join(", ")}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
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
  void cerrarSesion() {
    Utilidades.cerrarSesion(context);
  }

  void obtenerUsuariosPaginadosConfiltros() {
    _usuarios = _controller.obtenerUsuariosPaginadosConfiltros(_paginaActual, _elementosPorPagina, _ciResidente, _palabraClaveNombre, _palabraClaveApellido);
    _cantidadDePaginas = _controller.calcularTotalPaginas(_elementosPorPagina, _ciResidente, _palabraClaveNombre, _palabraClaveApellido);
    setState(() {});
  }

  void obtenerUsuariosPaginadosBotonFiltrar() {
    _paginaActual = 1;
    obtenerUsuariosPaginadosConfiltros();
  }

  void obtenerUsuariosPaginados() {
    limpiarFiltros();
    obtenerUsuariosPaginadosConfiltros();
  }

  void limpiarFiltros() {
    _paginaActual = 1;
    _palabraClaveNombre = null;
    _palabraClaveApellido = null;
    _ciResidente = null;
    _palabraClaveNombreController.clear();
    _palabraClaveApellidoController.clear();
    _ciResidenteController.clear();
  }
}
