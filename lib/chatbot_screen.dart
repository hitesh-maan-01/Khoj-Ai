import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile(path: 'assets/khoj_ai_bot.json')
        .then((instance) => dialogFlowtter = instance);
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      messages.add({'text': text, 'isUser': true});
    });

    final response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    final botText = response.text ?? "Sorry, I didn't get that.";

    setState(() {
      messages.add({'text': botText, 'isUser': false});
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Khoj AI Chatbot"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent,
          shadows: [
            Shadow(color: Colors.blueAccent, blurRadius: 12),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 🌌 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg/futuristic_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🧊 Blur Overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // 💬 Chat UI
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          horizontalOffset: msg['isUser'] ? 50.0 : -50.0,
                          child: FadeInAnimation(
                            child: Align(
                              alignment: msg['isUser']
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(14),
                                constraints:
                                    const BoxConstraints(maxWidth: 280),
                                decoration: BoxDecoration(
                                  color: msg['isUser']
                                      ? Colors.blueAccent.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: msg['isUser']
                                          ? Colors.blueAccent.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  msg['text'],
                                  style: TextStyle(
                                    color: msg['isUser']
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 🧠 Input Field + Mic + Send
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Ask something...",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.cyanAccent),
                      onPressed: () {
                        // 🔊 Voice input logic can go here
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.cyanAccent),
                      onPressed: () => sendMessage(_controller.text.trim()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
