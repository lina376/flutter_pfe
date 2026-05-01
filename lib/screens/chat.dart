import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ora/controlleurs/controleur_chat.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ora/models/modele_contexte.dart';
import 'maps.dart';

class chat extends StatefulWidget {
  static const String screenRoute = 'pagechat';

  const chat({super.key});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  final ControleurChat _controleurChat = ControleurChat();
  final stt.SpeechToText _speech = stt.SpeechToText();
  ModeleContexte? contexteActuel;
  String? conversationId;

  final TextEditingController controleurMessage = TextEditingController();
  final FocusNode focusTexte = FocusNode();

  bool _microDisponible = false;
  bool _estEnEcoute = false;
  bool _isSending = false;
  String _texteEcoute = "";

  @override
  void initState() {
    super.initState();
    _initialiserMicro();
  }

  String extractDestination(String message) {
    final regex = RegExp(r"vers (.+)", caseSensitive: false);
    final match = regex.firstMatch(message);

    if (match != null) {
      return match.group(1)!.trim();
    }

    return ""; // fallback
  }

  Future<void> _initialiserMicro() async {
    final disponible = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;

        if (status == 'notListening' || status == 'done') {
          setState(() {
            _estEnEcoute = false;
          });
        }
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _estEnEcoute = false;
        });
      },
      debugLogging: true,
    );

    if (!mounted) return;

    setState(() {
      _microDisponible = disponible;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      conversationId ??= args;
    } else if (args is Map<String, dynamic>) {
      final idConversation = args['conversationId'];
      final contexte = args['contexte'];

      if (idConversation is String) {
        conversationId ??= idConversation;
      }

      if (contexte is ModeleContexte) {
        contexteActuel = contexte;
      } else if (contexte is Map<String, dynamic>) {
        contexteActuel = ModeleContexte.fromMap(contexte);
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    controleurMessage.dispose();
    focusTexte.dispose();
    super.dispose();
  }

  Future<void> envoyerMessage() async {
    final texte = controleurMessage.text.trim();

    if (texte.isEmpty || conversationId == null || _isSending) return;

    setState(() {
      _isSending = true;
      _texteEcoute = "";
      _estEnEcoute = false;
    });

    controleurMessage.clear();

    await _controleurChat.ajouterMessage(
      conversationId: conversationId!,
      texte: texte,
      contexte: contexteActuel,
    );
  }

  Future<void> demarrerEcoute() async {
    if (!_microDisponible || _isSending) return;

    if (_speech.isListening) {
      await _speech.stop();
    }

    await _speech.listen(
      localeId: 'ar_AR',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 10),
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          if (result.finalResult) {
            _texteEcoute += " ${result.recognizedWords}";
            controleurMessage.text = _texteEcoute.trim();

            controleurMessage.selection = TextSelection.fromPosition(
              TextPosition(offset: controleurMessage.text.length),
            );
          }

          controleurMessage.selection = TextSelection.fromPosition(
            TextPosition(offset: controleurMessage.text.length),
          );
        });
      },
    );

    if (!mounted) return;

    setState(() {
      _estEnEcoute = true;
    });
  }

  Future<void> arreterEcoute() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _estEnEcoute = false;
    });
  }

  Future<void> basculerEcoute() async {
    if (_estEnEcoute) {
      await arreterEcoute();
    } else {
      await demarrerEcoute();
    }
  }

  Future<void> passerEnModeVocal() async {
    FocusScope.of(context).unfocus();
    await basculerEcoute();
  }

  Widget _buildAvatarOra() {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage("images/robot3.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isUser,
    required String texte,
    required String heure,
  }) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 260),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(232, 24, 2, 48).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
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
    );

    if (isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatarOra(),
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatarOra(),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(232, 24, 2, 48).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
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
                bottom: clavier + 90,
                child: conversationId == null || user == null
                    ? Center(
                        child: Text(
                          "app.loading".tr(),
                          style: const TextStyle(
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
                            return Center(
                              child: Text(
                                "app.loading".tr(),
                                style: const TextStyle(
                                  color: Color.fromARGB(179, 65, 24, 106),
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return Center(
                              child: Text(
                                "chat.no_messages".tr(),
                                style: const TextStyle(
                                  color: Color.fromARGB(179, 65, 24, 106),
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }

                          final messages = snapshot.data!.docs;

                          if (_isSending && messages.isNotEmpty) {
                            final dernierMessage = messages.first.data();
                            final dernierSender =
                                (dernierMessage['sender'] ?? 'user')
                                    .toString()
                                    .toLowerCase();

                            if (dernierSender == 'ora') {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                setState(() {
                                  _isSending = false;
                                });
                              });
                            }
                          }

                          if (messages.isEmpty && !_isSending) {
                            return Center(
                              child: Text(
                                "chat.no_messages".tr(),
                                style: const TextStyle(
                                  color: Color.fromARGB(179, 65, 24, 106),
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            reverse: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.manual,
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: messages.length + (_isSending ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (_isSending && index == 0) {
                                return _buildTypingBubble();
                              }

                              final vraiIndex = _isSending ? index - 1 : index;
                              final data = messages[vraiIndex].data();

                              final texte = (data['texte'] ?? '').toString();
                              final sender = (data['sender'] ?? 'user')
                                  .toString()
                                  .toLowerCase();
                              final isUser = sender == 'user';
                              final Timestamp? dateMessage =
                                  data['date'] as Timestamp?;
                              final heure = _controleurChat.formaterHeure(
                                dateMessage,
                              );

                              Widget messageWidget = _buildMessageBubble(
                                isUser: isUser,
                                texte: texte,
                                heure: heure,
                              );
                              if (!isUser &&
                                  texte.toLowerCase().contains(
                                    "voir le trajet",
                                  )) {
                                final destination = extractDestination(texte);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    messageWidget,

                                    if (destination.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 55,
                                        ),
                                        child: TextButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              MapsPage.screenRoute,
                                              arguments: {
                                                'destination': destination,
                                              },
                                            );
                                          },
                                          icon: const Icon(Icons.map),
                                          label: Text(
                                            "Voir trajet vers $destination",
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }

                              return messageWidget;
                            },
                          );
                        },
                      ),
              ),
              if (_estEnEcoute || _texteEcoute.isNotEmpty)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: clavier + 74,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _texteEcoute.isEmpty
                          ? "chat.listening".tr()
                          : _texteEcoute,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              Positioned(
                left: 10,
                right: 10,
                bottom: clavier + 8,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _isSending ? null : passerEnModeVocal,
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
                        child: Icon(
                          _estEnEcoute ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                        ),
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
                          enabled: !_isSending,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "chat.type_message".tr(),
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => envoyerMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _isSending ? null : envoyerMessage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.25),
                        ),
                        child: Icon(
                          Icons.send,
                          color: _isSending ? Colors.white54 : Colors.white,
                        ),
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

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacityForDot(int index) {
    final value = _controller.value;
    final shifted = (value - index * 0.2) % 1.0;
    if (shifted < 0) return 0.3;
    return 0.3 + (0.7 * (1 - shifted)).clamp(0.0, 1.0);
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityForDot(index),
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_buildDot(0), _buildDot(1), _buildDot(2)],
    );
  }
}
