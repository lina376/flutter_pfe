import 'package:flutter/material.dart';

class rencontre extends StatefulWidget {
  const rencontre({super.key});

  @override
  State<rencontre> createState() => _rencontreState();
}

class _rencontreState extends State<rencontre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(
                Color.fromARGB(194, 88, 70, 142),
              ),
            ),
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {},
            tooltip: 'home',
            iconSize: 40,
            constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b4.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                top: 150,
                left: 40,
                right: -30,
                child: Opacity(
                  opacity: 1,
                  child: Image.asset(
                    "images/robot0.png",
                    fit: BoxFit.contain,
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
