import 'package:flutter/material.dart';

class principal extends StatefulWidget {
  const principal({super.key});

  @override
  State<principal> createState() => _principalState();
}

class _principalState extends State<principal> {
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
                Color.fromARGB(92, 88, 70, 142),
              ),
            ),
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {},
            tooltip: 'home',
            iconSize: 25,
            constraints: const BoxConstraints(minHeight: 25, minWidth: 25),
          ),
        ],
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(89, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
          tooltip: 'home',
          iconSize: 25,
          constraints: const BoxConstraints(minHeight: 25, minWidth: 25),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 1,
                child: SizedBox(
                  width: 390,
                  height: 45,
                  child: SearchBarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color.fromARGB(159, 255, 255, 255).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              style: TextStyle(color: Color.fromARGB(75, 255, 255, 255)),
              decoration: InputDecoration(
                hintText: "Chercher",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.mic, color: Colors.white),
        ],
      ),
    );
  }
}
