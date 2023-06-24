import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaUsuarios.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaAltaFuncionario.dart';

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
                String subtitleText =
                    'Documento identificador: ${usuario.ci}, Administrador: $adminText, Roles: ${usuario.roles?.map((rol) => rol.toStringMostrar()).join(", ")}, Sucursales: ${usuario.getSucursales()?.map((sucursal) => sucursal.toStringMostrar()).join(", ")}';

                if (usuario.esResidente()) {
                  subtitleText +=
                      ', Familiares: ${usuario.getfamiliares()?.map((familiar) => familiar.toStringMostrar()).join(", ")}';
                }
                return ListTile(
                  title: Text(usuario.nombre ?? ""),
                  subtitle: Text(subtitleText),
                );
              },
            );
          }
        },
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
