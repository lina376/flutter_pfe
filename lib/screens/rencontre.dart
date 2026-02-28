import 'package:flutter/material.dart';
import 'package:ora/screens/connecter.dart';

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
                top: MediaQuery.of(context).size.height * 0.1,

                bottom: MediaQuery.of(context).size.height * -0.1,
                child: Opacity(
                  opacity: 1,
                  child: Image.asset(
                    "images/robot0.png",
                    fit: BoxFit.contain,
                    width: 20,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.025,
                left: MediaQuery.of(context).size.height * 0.065,
                child: Text(
                  "Rencontrez",
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.08,
                left: MediaQuery.of(context).size.height * 0.15,
                child: Text(
                  "ORA",
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF67A9FF),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.2,
                left: MediaQuery.of(context).size.height * 0.02,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Text(
                    "Avez-vous besoin\nd'aide?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              _buttomcommencer(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const connecter()),
                  );
                },
              ),
              Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.28,
                    left: MediaQuery.of(context).size.height * 0.18,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.3,
                    left: MediaQuery.of(context).size.height * 0.2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.31,
                    left: MediaQuery.of(context).size.height * 0.22,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _buttomcommencer extends StatelessWidget {
  final VoidCallback onTap;
  const _buttomcommencer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.02,
      right: MediaQuery.of(context).size.height * 0.02,
      left: MediaQuery.of(context).size.height * 0.02,
      child: GestureDetector(
        onTap: () {},

        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),

          child: Row(
            children: [
              const SizedBox(width: 10),

              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Center(
                  child: Text(
                    "Commencer",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 44), //position de commencer
            ],
          ),
        ),
      ),
    );
  }
}
