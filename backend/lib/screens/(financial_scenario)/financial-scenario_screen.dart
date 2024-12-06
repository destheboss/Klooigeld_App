import 'package:flutter/material.dart';

class FinancialScenarioLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatBubbleScreen(),
    );
  }
}

class ChatBubbleScreen extends StatefulWidget {
  @override
  _ChatBubbleScreenState createState() => _ChatBubbleScreenState();
}

class _ChatBubbleScreenState extends State<ChatBubbleScreen> {
  bool showReplyBubble = false;

  void toggleBubble() {
    setState(() {
      showReplyBubble = true; // Show the reply bubble after the first is tapped.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finance Stuff"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
 Padding(
            padding: const EdgeInsets.only(left: 20.0),  // Space from the left side
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align the children to the start (left)
              children: [
                Container(
                  height: 30,
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Grey color for the bar
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Add some spacing between the containers
                Container(
                  child: Text("1000.00 K"),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: toggleBubble,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First bubble always displayed
                    ChatBubble(
                      text: "Hello! I love money <3.",
                      isFromLeft: true,
                      icon: Icons.message,
                    ),
                    const SizedBox(height: 20), // Space between bubbles
                    // Second bubble conditionally displayed
                    if (showReplyBubble)
                      ChatBubble(
                        text: "Hi there! Me too!!",
                        isFromLeft: false,
                        icon: Icons.reply,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isFromLeft;
  final IconData icon;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isFromLeft,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isFromLeft
          ? [
              Icon(icon, color: Colors.teal, size: 24),
              SizedBox(width: 8),
              Bubble(text: text, isFromLeft: isFromLeft),
            ]
          : [
              Bubble(text: text, isFromLeft: isFromLeft),
              SizedBox(width: 8),
              Icon(icon, color: Colors.teal, size: 24),
            ],
    );
  }
}

class Bubble extends StatelessWidget {
  final String text;
  final bool isFromLeft;

  const Bubble({
    Key? key,
    required this.text,
    required this.isFromLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: isFromLeft ? Colors.teal.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFromLeft ? 0 : 15),
          topRight: Radius.circular(isFromLeft ? 15 : 0),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
