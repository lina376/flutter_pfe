import 'package:flutter/material.dart';

class chat extends StatefulWidget {
  const chat({super.key});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
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
            image: AssetImage("images/b1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                top: -150,
                left: -230,
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset("images/robot1.png", fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 590,
                left: 156,
                child: GestureDetector(
                  onTap: () {
                    // hne chn7ot code l ta3 tasjil
                  },
                  child: Container(
                    //bech ykoun mdawr
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          //wrah dhaw
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.mic, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 620,
                left: 300,
                child: GestureDetector(
                  onTap: () {
                    // hne chn7ot code l ta3 tasjil
                  },
                  child: Container(
                    //bech ykoun mdawr
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          //wrah dhaw
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.draw_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
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
