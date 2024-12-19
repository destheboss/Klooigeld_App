import 'package:backend/services/financial-scenario-service.dart';
import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FinancialScenarioLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FinancialScenarioScreen(),
    );
  }
}

class FinancialScenarioScreen extends StatefulWidget {
  @override
  _FinancialScenarioScreenState createState() =>
      _FinancialScenarioScreenState();
}

class _FinancialScenarioScreenState extends State<FinancialScenarioScreen> {
  double money = 1000.00;
  double progressvalue = 0.0;
  
  List<Widget> chatBubbles = [
    ChatBubble(
      text: "Hey! Do you want to go to the concert this weekend?",
      isFromLeft: true, // Text comes from the left
      icon: Icons.girl_rounded, // Icon for the chat
    ),
  ];

  bool showAnswers = true; // Flag to show/hide answers
  bool hasFollowUp = false; // Flag to ensure follow-up question is asked only once
  bool showFollowUpAnswers = false; // Flag to show follow-up answers

  void addAnswer(String answer, double cost) {
    setState(() {
      money -= cost; 
      progressvalue += 0.5;

      chatBubbles.add(ChatBubble(
        text: answer,
        isFromLeft: false, // Text comes from the right
        icon: Icons.person,
      ));
      showAnswers = false; // Hide the answers after one is selected

      // Add follow-up question once after the first answer is selected
      if (!hasFollowUp) {
        hasFollowUp = true;
        chatBubbles.add(ChatBubble(
          text: "Do you want to grab a drink at the concert?",
          isFromLeft: true,
          icon: Icons.girl_rounded,
        ));
        showFollowUpAnswers = true; 
      }

      if (progressvalue >= 1.0) {
        _showEndPopup();
      }
    });
  }

  void addFollowUpAnswer(String answer, double cost) {
    setState(() {
      money -= cost; 
      progressvalue += 0.5;

      chatBubbles.add(ChatBubble(
        text: answer,
        isFromLeft: false,
        icon: Icons.person, 
      ));
      showFollowUpAnswers = false;


      if (progressvalue >= 1.0) {
        _showEndPopup();
      }
    });
  }

  void _showEndPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End"),
          content: Text("You have completed the scenario!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Progress Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(                  
                      value: progressvalue, // progress
                      backgroundColor: Colors.grey.shade300,
                      color:AppTheme.klooigeldGroen,
                      minHeight: 8,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "\$${money.toStringAsFixed(2)}", // Money text with 2 decimal points
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Chat Bubbles with Padding
          Expanded(
            child: ListView.builder(
              itemCount: chatBubbles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0), // Add padding to each chat bubble
                  child: chatBubbles[index],
                );
              },
            ),
          ),

          // Answer Options
          if (showAnswers) 
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  AnswersBox(
                    answer: "Sure, I'll go!",
                    cost: 100.00,
                    onTap: () => addAnswer("Sure, I'll go!", 100.00),
                  ),
                  SizedBox(height: 10),
                  AnswersBox(
                    answer: "I can't afford it.",
                    cost: 0.00,
                    onTap: () => addAnswer("I can't afford it.", 0.00),
                  ),
                ],
              ),
            ),

          // Follow-up Answer Options
          if (showFollowUpAnswers)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  AnswersBox(
                    answer: "Yes, let's do it!",
                    cost: 50.00,
                    onTap: () => addFollowUpAnswer("Yes, let's do it!", 50.00),
                  ),
                  SizedBox(height: 10),
                  AnswersBox(
                    answer: "No, I'm good for now.",
                    cost: 0.00,
                    onTap: () => addFollowUpAnswer("No, I'm good for now.", 0.00),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
