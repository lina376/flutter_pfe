import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ora/controllers/controleur_chat.dart';

class chat extends StatefulWidget {
  static const String screenRoute = 'pagechat';
  const chat({super.key});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  final ControleurChat _controleurChat = ControleurChat();

  bool modeVocal = true;
  String? conversationId;

  final TextEditingController controleurMessage = TextEditingController();
  final FocusNode focusTexte = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      conversationId ??= args;
    }
  }

  @override
  void dispose() {
    controleurMessage.dispose();
    focusTexte.dispose();
    super.dispose();
  }

  Future<void> envoyerMessage() async {
    final texte = controleurMessage.text.trim();

    if (texte.isEmpty || conversationId == null) return;

    await _controleurChat.ajouterMessage(
      conversationId: conversationId!,
      texte: texte,
    );

    controleurMessage.clear();
  }

  void passerEnModeVocal() {
    FocusScope.of(context).unfocus();
    setState(() => modeVocal = true);
  }

  void passerEnModeEcriture() {
    setState(() => modeVocal = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(focusTexte);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _controleurChat.obtenirUtilisateurActuel();
    final hauteur = MediaQuery.of(context).size.height;
    final clavier = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(87, 27, 2, 48),
        elevation: 0,
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              Color.fromARGB(194, 88, 70, 142),
            ),
          ),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'chevron',
          iconSize: 40,
          constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/b1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                top: hauteur * -0.2,
                left: hauteur * -0.4,
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset("images/robot1.png", fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: hauteur * 0.12,
                left: 12,
                right: 12,
                bottom: modeVocal ? 140 : clavier + 70,
                child: conversationId == null || user == null
                    ? const Center(
                        child: Text(
                          "Chargement...",
                          style: TextStyle(
                            color: Color.fromARGB(152, 65, 24, 106),
                          ),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _controleurChat.obtenirFluxMessages(
                          conversationId: conversationId!,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Text(
                                "Chargement...",
                                style: TextStyle(
                                  color: Color.fromARGB(179, 65, 24, 106),
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "Aucun message",
                                style: TextStyle(
                                  color: Color.fromARGB(179, 65, 24, 106),
                                ),
                              ),
                            );
                          }

                          final messages = snapshot.data!.docs;

                          return ListView.builder(
                            reverse: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.manual,
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final data = messages[index].data();

                              final texte = (data['texte'] ?? '').toString();
                              final sender = (data['sender'] ?? 'user')
                                  .toString();
                              final isUser = sender == 'user';
                              final Timestamp? dateMessage =
                                  data['date'] as Timestamp?;
                              final heure = _controleurChat.formaterHeure(
                                dateMessage,
                              );

                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      232,
                                      24,
                                      2,
                                      48,
                                    ).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        texte,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        heure,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 10,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              if (modeVocal)
                Positioned(
                  top: hauteur * 0.7,
                  left: hauteur * 0.2,
                  child: GestureDetector(
                    onTap: passerEnModeVocal,
                    child: Container(
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
                  top: hauteur * 0.77,
                  left: hauteur * 0.35,
                  child: GestureDetector(
                    onTap: passerEnModeEcriture,
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
                        boxShadow: [
                          BoxShadow(
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
              if (!modeVocal)
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: clavier + 8,
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
                            textInputAction: TextInputAction.send,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Écrire...",
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => envoyerMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: envoyerMessage,
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
          ),
        ),
      ),
    );
  }
}
