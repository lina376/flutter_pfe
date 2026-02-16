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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b1.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFFF5DAFF)),
            ),
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {},
            tooltip: 'home',
          ),
        ],
      ),
    );
  }
}
