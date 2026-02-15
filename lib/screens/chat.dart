import 'package:flutter/material.dart';

class chatora extends StatefulWidget {
  const chatora({super.key});

  @override
  State<chatora> createState() => _chatoraState();
}

class _chatoraState extends State<chatora> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFFF5DAFF)),
            ),
            iconSize: 20,
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {},
            tooltip: 'home',
          ),
        ],
      ),
    );
  }
}
