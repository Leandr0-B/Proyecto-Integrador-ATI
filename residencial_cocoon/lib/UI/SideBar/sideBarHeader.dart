import 'package:flutter/material.dart';

class MyHederDrawer extends StatefulWidget {
  const MyHederDrawer({super.key});

  @override
  _MyHederDrawerState createState() => _MyHederDrawerState();
}

class _MyHederDrawerState extends State<MyHederDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[700],
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
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/menu.jpg'),
              ),
            ),
          ),
          const Text(
            "Rapid Tech",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            "info bla bla",
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
