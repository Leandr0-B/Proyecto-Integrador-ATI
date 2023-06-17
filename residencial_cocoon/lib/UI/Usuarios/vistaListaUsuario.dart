import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaUsuarios.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaAltaUsuario.dart';

class VistaListaUsuario extends StatefulWidget {
  @override
  _VistaListaUsuarioState createState() => _VistaListaUsuarioState();
}

class _VistaListaUsuarioState extends State<VistaListaUsuario> {
  ControllerVistaUsuarios? controller;

  @override
  void initState() {
    super.initState();
    controller = ControllerVistaUsuarios(mostrarMensaje: mostrarMensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Usuarios',
          style: TextStyle(color: Colors.black), // Cambia a tu color preferido.
        ),
        backgroundColor: Color.fromARGB(195, 190, 190, 180),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Usuario>>(
        future: obtenerUsuarios(),
        builder: (BuildContext context, AsyncSnapshot<List<Usuario>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Si todo sale bien, mostramos la lista de usuarios
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Usuario usuario = snapshot.data![index];
                String adminText = usuario.administrador == 1 ? 'Si' : 'No';
                return ListTile(
                  title: Text(usuario.nombre),
                  subtitle: Text(
                    'CI: ${usuario.ci}, Administrador: $adminText, Roles: ${usuario.getRoles()?.map((rol) => rol.toStringMostrar()).join(", ")}, Sucursales: ${usuario.getSucursales()?.map((sucursal) => sucursal.toStringMostrar()).join(", ")}, Familiares: ${usuario.getfamiliares()?.map((familiar) => familiar.toStringMostrar()).join(", ")}',
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => NuevoUsuarioPage()),
          // );
          //Navigator.pushReplacementNamed(context, NuevoUsuarioPage.id);
          Navigator.pushNamed(context, VistaAltaUsuario.id);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
    ));
  }

  Future<List<Usuario>> obtenerUsuarios() async {
    return await controller?.obtenerUsuarios() ?? [];
  }
}
