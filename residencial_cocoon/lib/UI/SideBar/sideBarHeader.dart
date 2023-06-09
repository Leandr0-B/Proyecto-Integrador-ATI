import 'package:flutter/material.dart';

class SideBarHeader extends StatefulWidget {
  const SideBarHeader({super.key});

  @override
  _SideBarHeaderState createState() => _SideBarHeaderState();
}

class _SideBarHeaderState extends State<SideBarHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                image: AssetImage('assets/images/menu.jpg'),
              ),
            ),
          ),
          const Text(
            "Grupo Cocoon",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          const Text(
            "094 606 032  grupo@cocoon.uy",
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
