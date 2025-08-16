import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isBotTyping = false;

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile(path: 'assets/khoj_ai_bot.json')
        .then((instance) => dialogFlowtter = instance);

    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode); // Auto keyboard
    });
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      messages.add({'text': text, 'isUser': true});
      _isBotTyping = true;
    });

    final response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    final botText = response.text ?? "Sorry, I didn't get that.";

    await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay

    setState(() {
      messages.add({'text': botText, 'isUser': false, 'animated': true});
      _isBotTyping = false;
    });

    _controller.clear();
  }

  Widget typingIndicator() => Row(
        children: [
          const SizedBox(width: 10),
          const Text("Khoj AI is thinking...",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 10),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color.fromARGB(255, 13, 71, 161),
            ),
          ),
        ],
      );

  Widget buildMessage(Map<String, dynamic> msg) {
    return Align(
      alignment: msg['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg['isUser']
              ? const Color.fromARGB(255, 13, 71, 161)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: msg['animated'] == true
            ? AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    msg['text'],
                    textStyle:
                        const TextStyle(fontSize: 15, color: Colors.black87),
                    speed: const Duration(milliseconds: 40),
                  ),
                ],
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 500),
                displayFullTextOnTap: true,
              )
            : Text(
                msg['text'],
                style: TextStyle(
                  fontSize: 15,
                  color: msg['isUser'] ? Colors.white : Colors.black87,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Khoj AI Chatbot"),
        backgroundColor: const Color.fromARGB(255, 13, 71, 163),
        titleTextStyle:
            TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 20),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isBotTyping && index == messages.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: typingIndicator(),
                  );
                }
                return buildMessage(messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color.fromARGB(255, 13, 71, 163)),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
