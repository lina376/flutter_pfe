import 'package:flutter/material.dart';

class chat extends StatefulWidget {
  static const String screenRoute = 'pagechat';
  const chat({super.key});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  bool modeVocal = true; // true = micro / false = écriture

  final TextEditingController controleurMessage = TextEditingController();
  final FocusNode focusTexte = FocusNode();

  @override
  void dispose() {
    controleurMessage.dispose();
    focusTexte.dispose();
    super.dispose();
  }

  void passerEnModeVocal() {
    FocusScope.of(context).unfocus(); //ykhabi l clavier
    setState(() => modeVocal = true);
  }

  void passerEnModeEcriture() {
    setState(() => modeVocal = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusTexte);
    });
  }

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
                top: MediaQuery.of(context).size.height * -0.2,
                left: MediaQuery.of(context).size.height * -0.4,
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset("images/robot1.png", fit: BoxFit.cover),
                ),
              ),
              if (modeVocal)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.7,
                  left: MediaQuery.of(context).size.height * 0.2,
                  child: GestureDetector(
                    onTap: passerEnModeVocal,
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
              if (modeVocal)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.77,
                  left: MediaQuery.of(context).size.height * 0.35,
                  child: GestureDetector(
                    onTap: passerEnModeEcriture,
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
              if (!modeVocal) ...[
                Positioned(
                  left: MediaQuery.of(context).size.height * 0,
                  right: MediaQuery.of(context).size.height * 0,
                  bottom: MediaQuery.of(context).size.height * 0.01,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: passerEnModeVocal,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.mic, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: TextField(
                            focusNode: focusTexte,
                            controller: controleurMessage,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Écrire...",
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
