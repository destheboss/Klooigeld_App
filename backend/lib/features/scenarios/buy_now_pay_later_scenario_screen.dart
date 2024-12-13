// lib/features/scenarios/buy_now_pay_later_scenario_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend/theme/app_theme.dart';
import 'buy_now_pay_later_scenario_data.dart';
import 'models/scenario_model.dart';
import 'models/scenario_choice.dart';
import 'widgets/scenario_header.dart';
import 'widgets/scenario_message_bubble.dart';
import 'widgets/scenario_choices_list.dart';
import 'widgets/custom_dialog.dart';
import '../../../screens/(rewards)/rewards_shop_screen.dart';

class BuyNowPayLaterScenarioScreen extends StatefulWidget {
  const BuyNowPayLaterScenarioScreen({Key? key}) : super(key: key);

  @override
  State<BuyNowPayLaterScenarioScreen> createState() =>
      _BuyNowPayLaterScenarioScreenState();
}

class _BuyNowPayLaterScenarioScreenState
    extends State<BuyNowPayLaterScenarioScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late ScenarioModel _scenario;
  int _currentScenarioIndex = 0;
  int _klooicash = 0; // Changed from double to int

  // New Variables
  int _originalBalance = 0; // Stores the original balance when entering the game
  int _accumulatedDeductions = 0; // Tracks total in-game deductions


  bool _isLoading = true;
  bool _showChoices = true;
  bool _scenarioCompleted = false;
  bool _showNextButton = false;
  int _bestScore = 0;

  List<Map<String, dynamic>> _chatMessages = [];

  String _username = "You";
  String? _avatarImagePath;

  final ScrollController _scrollController = ScrollController();

  bool _flowersPurchased = false; // ID 201
  bool _chocolatesPurchased = false; // ID 202

  final List<Color> _optionColors = [
    AppTheme.klooigeldRoze,
    AppTheme.klooigeldGroen,
    AppTheme.klooigeldPaars,
    AppTheme.klooigeldBlauw
  ];

  bool _scenarioFirstTime = true;
  bool _resumed = false;
  int _initialK = 0; // Changed from double to int

  // Store user choices for final analysis
  List<ScenarioChoice> _userChoices = [];

  // Track if last choice was BNPL to show reminder next
  bool _lastChoiceWasBNPL = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for app lifecycle
    _scenario = buildBuyNowPayLaterScenario();
    _initializeScenario();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _saveCurrentStep(); // Ensure state is saved when disposing
    super.dispose();
  }

  /// Handles app lifecycle changes to save state when the app is backgrounded
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // **Only save progress if beyond step 0**
      if (_currentScenarioIndex > 0) {
        _saveCurrentStep(); // Save state when app is paused
      }
    }
  }

  int _retrieveBalance(SharedPreferences prefs) {
    final balance = prefs.get('klooicash'); // Get the value without assuming type
    if (balance is int) {
      return balance;
    } else if (balance is double) {
      return balance.toInt(); // Convert double to int
    } else {
      return 500; // Default fallback value
    }
  }

 Future<void> _initializeScenario() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve stored data
  _bestScore = prefs.getInt('best_score_buynowpaylater') ?? 0;
  _username = prefs.getString('username') ?? 'You';
  _avatarImagePath = prefs.getString('avatarImagePath');

  // Retrieve the current main balance
  int currentMainBalance = _retrieveBalance(prefs);

  // Retrieve original balance; if not set, initialize it to current main balance
  _originalBalance = prefs.getInt('scenario_buynowpaylater_original_balance') ?? currentMainBalance;

  // If original balance is not set, save it now
  if (!prefs.containsKey('scenario_buynowpaylater_original_balance')) {
    await prefs.setInt('scenario_buynowpaylater_original_balance', _originalBalance);
  }

  // Retrieve accumulated deductions
  _accumulatedDeductions = prefs.getInt('scenario_buynowpaylater_accumulated_deductions') ?? 0;

  // Recalculate temporary balance based on current main balance and accumulated deductions
  _klooicash = currentMainBalance - _accumulatedDeductions;

  bool completedBefore = prefs.getBool('scenario_buynowpaylater_completed') ?? false;
  _scenarioFirstTime = !completedBefore;

  int savedStep = prefs.getInt('scenario_buynowpaylater_currentStep') ?? 0;

  // Load purchase flags from both scenario-specific flags and rewards shop purchases
  _flowersPurchased = prefs.getBool('scenario_buynowpaylater_flowersPurchased') ?? false;
  _chocolatesPurchased = prefs.getBool('scenario_buynowpaylater_chocolatesPurchased') ?? false;

  // Additionally, check if items were purchased from the Rewards Shop
  List<String> purchasedItems = prefs.getStringList('purchasedItems') ?? [];
  if (purchasedItems.contains('201')) {
    _flowersPurchased = true;
  }
  if (purchasedItems.contains('202')) {
    _chocolatesPurchased = true;
  }

  // Restore chat messages
  List<String>? storedMessages = prefs.getStringList('scenario_buynowpaylater_chatMessages');
  if (storedMessages != null) {
    _chatMessages = storedMessages.map((msg) => jsonDecode(msg) as Map<String, dynamic>).toList();
  }

  // Restore UI state flags
  _showNextButton = prefs.getBool('scenario_buynowpaylater_showNextButton') ?? false;
  _showChoices = prefs.getBool('scenario_buynowpaylater_showChoices') ?? true;

  // Restore the BNPL flag
  _lastChoiceWasBNPL = prefs.getBool('scenario_buynowpaylater_lastChoiceWasBNPL') ?? false;

  bool dialogShown = false;

  // Ask user whether to resume or restart if there's any progress beyond step 0
  if (!completedBefore && savedStep > 0 && storedMessages != null && storedMessages.isNotEmpty) {
    bool? resume = await _askResumeOrRestart();
    if (resume == true) {
      _currentScenarioIndex = savedStep;
      _resumed = true;
    } else {
      // Restart scenario
      _currentScenarioIndex = 0;
      _klooicash = currentMainBalance; // Reset to current main balance
      _chatMessages.clear(); // Clear chat messages
      _userChoices.clear();

      // Reset UI state flags
      _showNextButton = false;
      _showChoices = true;

      // Reset accumulated deductions
      _accumulatedDeductions = 0;
      await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', _accumulatedDeductions);

      // Clear saved state as user chose to restart
      await _clearSavedState();
    }
  }

  setState(() {
    _isLoading = false;
  });

  // Trigger BNPL Reminder if applicable
  if (_lastChoiceWasBNPL) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBNPLReminder();
      dialogShown = true;
    });
  }

  Future.microtask(() {
    if (_chatMessages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottomWithAnimation();
      });
    } else {
      _addNPCMessage(
        _scenario.steps[_currentScenarioIndex].npcMessage,
        _scenario.steps[_currentScenarioIndex].npcName,
        animate: false,
      );
      _scrollToBottomWithAnimation();
    }
  });
}





  Future<bool?> _askResumeOrRestart() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        icon: FontAwesomeIcons.questionCircle,
        title: "Resume Scenario?",
        content: "You left this scenario before. Would you like to resume or restart?",
        actions: [
          // Use Row to keep buttons on the same line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Restart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false), // Restart
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klooigeldRozeAlt,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Restart",
                    style: TextStyle(
                      fontFamily: AppTheme.neighbor,
                      fontSize: 16,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12), // Space between buttons
              // Resume Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true), // Resume
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klooigeldBlauw,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Resume",
                    style: TextStyle(
                      fontFamily: AppTheme.neighbor,
                      fontSize: 16,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        closeValue: null,
      ),
    );
    return result;
  }

Future<void> _clearSavedState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('scenario_buynowpaylater_currentStep');
  await prefs.remove('scenario_buynowpaylater_chatMessages');
  await prefs.remove('scenario_buynowpaylater_accumulated_deductions');
  await prefs.remove('scenario_buynowpaylater_original_balance');

  // **Clear UI state flags**
  await prefs.remove('scenario_buynowpaylater_showNextButton');
  await prefs.remove('scenario_buynowpaylater_showChoices');

  // **Clear the BNPL flag**
  await prefs.remove('scenario_buynowpaylater_lastChoiceWasBNPL');
}

  void _addNPCMessage(String message, String speakerName, {bool animate = true}) {
    _chatMessages.add({
      "type": "npc",
      "speaker": speakerName,
      "message": message,
    });
    setState(() {});
    if (animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottomWithAnimation();
      });
    }
  }

  void _addUserMessage(String message) {
    _chatMessages.add({
      "type": "user",
      "speaker": _username,
      "message": message,
    });
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomWithAnimation();
    });
  }

  void _addOutcomeMessage(String outcome, int kChange) { // Changed kChange to int
    String feedback = "";
    if (kChange > 0) {
      feedback = " (+$kChange)";
    } else if (kChange < 0) {
      feedback = " ($kChange)";
    }

    String finalMessage = outcome + (_scenarioFirstTime ? feedback : "");

    _chatMessages.add({
      "type": "outcome",
      "message": finalMessage,
    });
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomWithAnimation();
    });
  }

  void _addDelimiter() {
    _chatMessages.add({
      "type": "delimiter",
    });
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomWithAnimation();
    });
  }

  void _addFinalFeedbackMessage(String feedback) {
    _chatMessages.add({
      "type": "outcome",
      "message": feedback,
    });
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomWithAnimation();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToBottomWithAnimation() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _onChoiceSelected(ScenarioChoice choice) async {
  setState(() {
    _showChoices = false;
    _showNextButton = true;
  });

  // Add user dialogue bubble using dialogueText from the choice
  _addUserMessage(choice.dialogueText);

  // Calculate the actual change in balance
  int actualChange = _scenarioFirstTime ? choice.kChange.toInt() : 0; // Ensure kChange is int
  if (actualChange < 0) {
    _accumulatedDeductions += -actualChange; // Accumulate deductions only for negative changes
  } else {
    _klooicash += actualChange; // Handle positive changes if applicable
  }

  // Recalculate temporary balance based on current main balance and accumulated deductions
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int currentMainBalance = _retrieveBalance(prefs);
  _klooicash = currentMainBalance - _accumulatedDeductions;

  // Check if BNPL choice
  _lastChoiceWasBNPL = false;
  if (choice.text.contains("Klaro")) {
    _lastChoiceWasBNPL = true;
  }

  _addOutcomeMessage(choice.outcome, choice.kChange.toInt());

  // Record the user choice
  _userChoices.add(choice);

  // If it's grandma gift and first time scenario, add the reward:
  if (_scenarioFirstTime) {
    if (choice.text.contains("flowers")) {
      _klooicash += 30;
      // Optionally, consider this as a positive change
    } else if (choice.text.contains("chocolates")) {
      _klooicash += 15;
      // Optionally, consider this as a positive change
    }
  }

  await _saveBalanceState();

  // **Only save progress if beyond step 0**
  if (_currentScenarioIndex > 0) {
    await _saveCurrentStep();
  }
}



  Future<void> _saveKlooicash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // **Modified to save to 'scenario_buynowpaylater_tempBalance' as int**
    await prefs.setInt('scenario_buynowpaylater_tempBalance', _klooicash); // Store as int
  }
Future<void> _saveBalanceState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Save the original balance (only if it's the first time)
  if (!_resumed) {
    await prefs.setInt('scenario_buynowpaylater_original_balance', _originalBalance);
  }
  
  // Save the accumulated deductions
  await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', _accumulatedDeductions);
  
  // Save the temporary balance
  await prefs.setInt('scenario_buynowpaylater_tempBalance', _klooicash);
}




  Future<void> _saveCurrentStep() async {
  // **Prevent saving if at step 0**
  if (_currentScenarioIndex <= 0) {
    return;
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('scenario_buynowpaylater_currentStep', _currentScenarioIndex);

  // Save chat messages as a list of strings
  List<String> serializedMessages = _chatMessages.map((msg) => jsonEncode(msg)).toList();
  await prefs.setStringList('scenario_buynowpaylater_chatMessages', serializedMessages);

  // Save the accumulated deductions
  await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', _accumulatedDeductions);

  // **Save UI state flags**
  await prefs.setBool('scenario_buynowpaylater_showNextButton', _showNextButton);
  await prefs.setBool('scenario_buynowpaylater_showChoices', _showChoices);

  // **Save the BNPL flag**
  await prefs.setBool('scenario_buynowpaylater_lastChoiceWasBNPL', _lastChoiceWasBNPL);
}




  Future<void> _goToNextScenario() async {
    setState(() {
      _showNextButton = false;
    });

    // If the last choice was BNPL, show a reminder now
    if (_lastChoiceWasBNPL) {
      _showBNPLReminder();
      _lastChoiceWasBNPL = false;
      await _saveCurrentStep();
      return;
    }

    if (_currentScenarioIndex < _scenario.steps.length - 1) {
      _currentScenarioIndex++;
      _addNPCMessage(
        _scenario.steps[_currentScenarioIndex].npcMessage,
        _scenario.steps[_currentScenarioIndex].npcName,
      );
      setState(() {
        _showChoices = true;
      });
      await _saveCurrentStep();
    } else {
      await _markLevelCompleted();
      setState(() {
        _scenarioCompleted = true;
      });
      _showEndScenarioFeedbackInChat();
    }
  }

    Future<void> _showBNPLReminder() async {
    // Determine the reminder message based on user choices
    String reminder;

    if (_userChoices.any((c) => c.text.contains("ticket via Klaro"))) {
      reminder = "Reminder: You need to pay Klaro for the concert ticket in a week!";
    } else if (_userChoices.any((c) => c.text.contains("new phone via Klaro"))) {
      reminder = "Reminder: Your phone bill with Klaro will be due in about a month!";
    } else {
      reminder = "Keep track of what you owe Klaro!";
    }

    var result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        icon: FontAwesomeIcons.moneyCheckAlt,
        title: "Klaro Reminder",
        content: reminder,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // "OK" returns true
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.klooigeldBlauw,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "OK",
              style: TextStyle(
                fontFamily: AppTheme.neighbor,
                fontSize: 16,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
        closeValue: true, // Specifies the return value
        actionsAlignment: MainAxisAlignment.end, // Explicitly pass alignment
      ),
    );

    print('BNPL Reminder dialog result: $result'); // Debugging statement

    // **Reset the BNPL flag before proceeding**
    if (result == true || result == null) {
      setState(() {
        _lastChoiceWasBNPL = false; // Reset the flag first
      });
      await _saveCurrentStep(); // Save state after resetting the flag
      _goToNextScenario(); // Now proceed to the next scenario
    } else {
      // Handle unexpected results if necessary
      print('Unexpected dialog result: $result');
    }
  }


  Future<void> _markLevelCompleted() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (_scenarioFirstTime) {
    if (_klooicash > 0) {
      int unlockedIndex = prefs.getInt('unlockedLevelIndex') ?? 0;
      if (unlockedIndex < 1) {
        unlockedIndex = 1;
        await prefs.setInt('unlockedLevelIndex', unlockedIndex);
      }
    }

    if (_klooicash > _bestScore) { // Changed to compare int
      _bestScore = _klooicash;
      await prefs.setInt('best_score_buynowpaylater', _bestScore);
    }

    await prefs.setBool('scenario_buynowpaylater_completed', true);
    await prefs.remove('scenario_buynowpaylater_currentStep');

    // **Update main balance with the final in-game balance**
    await prefs.setInt('klooicash', _klooicash); // Changed to setInt

    // **Remove the original balance and accumulated deductions as scenario is completed**
    await prefs.remove('scenario_buynowpaylater_original_balance');
    await prefs.remove('scenario_buynowpaylater_accumulated_deductions');

    // **Remove the temporary balance as scenario is completed**
    await prefs.remove('scenario_buynowpaylater_tempBalance');

    // **Clear UI state flags**
    await prefs.remove('scenario_buynowpaylater_showNextButton');
    await prefs.remove('scenario_buynowpaylater_showChoices');
  } else {
    // Replay scenario: revert klooicash
    int currentBalance = prefs.getInt('klooicash') ?? _originalBalance;
    if (currentBalance != _originalBalance) {
      await prefs.setInt('klooicash', _originalBalance);
      _klooicash = _originalBalance;
    }
    await prefs.remove('scenario_buynowpaylater_currentStep');

    // **Clear UI state flags**
    await prefs.remove('scenario_buynowpaylater_showNextButton');
    await prefs.remove('scenario_buynowpaylater_showChoices');

    // **Reset accumulated deductions for replay**
    _accumulatedDeductions = 0;
    await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', _accumulatedDeductions);
  }
}



  void _showEndScenarioFeedbackInChat() {
    _addDelimiter();

    // Analyze user choices and provide improved feedback
    String choiceAnalysis = _analyzeUserChoices();

    String finalMessage;
    if (_scenarioFirstTime) {
      if (_klooicash > 0) {
        finalMessage = "You finished with some money left. Good job on picking choices that kept you stable.\n\n" +
                       "Try replaying to see other outcomes, but no extra money next time.\n\n" + choiceAnalysis;
      } else {
        finalMessage = "You ended up with not much money. Some decisions may have made your future harder.\n\n" +
                       "Consider replaying and trying different paths, but no extra gains on replay.\n\n" + choiceAnalysis;
      }
    } else {
      if (_klooicash > 0) {
        finalMessage = "This replay shows you can do better with different choices. Your Klooicash goes back to normal now.\n\n" +
                       choiceAnalysis;
      } else {
        finalMessage = "Even on replay, your balance isn't that great. But you return to your original Klooicash.\n\n" +
                       choiceAnalysis;
      }
    }

    _addFinalFeedbackMessage(finalMessage);
  }

  String _analyzeUserChoices() {
    // Improved analysis to explain better/worse reasoning:
    // Steps:
    // - Concert: pay now vs Klaro
    // - Phone: pay now, Klaro, or keep cracked
    // - Grandma: flowers vs chocolates

    StringBuffer analysis = StringBuffer("Let’s look at each big choice and why it might be good or bad:\n\n");

    // Concert choice
    var concertChoice = _userChoices.length > 1 ? _userChoices[1].text : "";
    if (concertChoice.contains("Pay 20K now")) {
      analysis.writeln("Concert: You paid upfront. No future debt, safer in the long run.");
    } else if (concertChoice.contains("Use Klaro")) {
      analysis.writeln("Concert: You postponed the payment. Good short-term, but you’ll have to handle that debt soon.");
    }

    // Phone choice
    var phoneChoice = _userChoices.length > 3 ? _userChoices[3].text : "";
    if (phoneChoice.contains("Pay 70K now")) {
      analysis.writeln("Phone: You fixed it right away. Costly now, but no big debt later, giving you peace of mind.");
    } else if (phoneChoice.contains("new phone via Klaro")) {
      analysis.writeln("Phone: You got a new phone without paying now, but a huge 700K bill is waiting. This can become a serious problem later.");
    } else if (phoneChoice.contains("Keep it cracked")) {
      analysis.writeln("Phone: You saved money now, but dealing with a broken phone might cause trouble and stress.");
    }

    // Grandma choice
    var grandmaChoice = _userChoices.length > 5 ? _userChoices[5].text : "";
    if (grandmaChoice.contains("flowers")) {
      analysis.writeln("Grandma: You spent more (10K) but earned a bigger reward (30K). It’s a good deal and makes Grandma very happy.");
    } else if (grandmaChoice.contains("chocolates")) {
      analysis.writeln("Grandma: You spent less (5K) and earned less (15K). It’s okay, but not as profitable or as heartwarming as flowers.");
    }

    analysis.writeln("\nIn short, choices that avoid huge future debts or please others well give better rewards. BNPL (Klaro) can help short-term, but big debts might hurt you later. Small investments (like flowers) can pay off nicely.");

    return analysis.toString();
  }

  bool _shouldShowShop() {
    // The grandma gift scenario is at step 5 (0-based)
    // Show shop button when choosing grandma's gift.
    return _currentScenarioIndex == 5 && !_scenarioCompleted && _showChoices;
  }

  Future<void> _openShop() async {
  final purchasedNow = await showModalBottomSheet<Set<int>>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    builder: (context) {
      return RewardsShopScreen(
        isModal: true,
        initialCategoryId: 4,
        initialBalance: _klooicash, // Pass in-game balance
        onClose: () {
          Navigator.pop(context, <int>{});
        },
        onKlooicashUpdate: (newBalance) {
          setState(() {
            _klooicash = newBalance.toInt(); // Ensure it's int
          });
        },
      );
    },
  ) ?? <int>{};

  // Update purchase flags based on items bought
  setState(() {
    if (purchasedNow.contains(201)) {
      _flowersPurchased = true;
      print('Flowers purchased: $_flowersPurchased');
    }
    if (purchasedNow.contains(202)) {
      _chocolatesPurchased = true;
      print('Chocolates purchased: $_chocolatesPurchased');
    }
  });

  await _saveBalanceState();

  // Save the purchase flags to SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('scenario_buynowpaylater_flowersPurchased', _flowersPurchased);
  await prefs.setBool('scenario_buynowpaylater_chocolatesPurchased', _chocolatesPurchased);
}

  void _showAlert(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(fontFamily: AppTheme.neighbor, color: Colors.white),
      ),
      backgroundColor: AppTheme.klooigeldBlauw,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> _replayScenario() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Clear all scenario-related stored data except the original balance and main balance
  await prefs.remove('scenario_buynowpaylater_chatMessages');
  await prefs.remove('scenario_buynowpaylater_accumulated_deductions');
  await prefs.remove('scenario_buynowpaylater_currentStep');
  await prefs.remove('scenario_buynowpaylater_showNextButton');
  await prefs.remove('scenario_buynowpaylater_showChoices');
  await prefs.remove('scenario_buynowpaylater_lastChoiceWasBNPL');
  // Do not remove 'scenario_buynowpaylater_original_balance' here to retain the original balance

  setState(() {
    _currentScenarioIndex = 0;
    _showChoices = true;
    _scenarioCompleted = false;
    _chatMessages.clear(); // Clear chat messages
    _userChoices.clear(); // Clear user choices
    _klooicash = _originalBalance - _accumulatedDeductions; // Reset balance based on original balance and deductions
    _showNextButton = false;
    _lastChoiceWasBNPL = false;
    _scenarioFirstTime = true; // Explicitly set to true for replay
  });

  // Add the first message for the scenario
  _addNPCMessage(
    _scenario.steps[_currentScenarioIndex].npcMessage,
    _scenario.steps[_currentScenarioIndex].npcName,
    animate: false,
  );

  // Scroll to bottom to show the first message
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollToBottomWithAnimation();
  });
}




  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Progress at the end should be 1.0
    final totalSteps = _scenario.steps.length;
    final progress = (_currentScenarioIndex + (_showChoices ? 0 : 1)) / totalSteps;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _shouldShowShop()
          ? FloatingActionButton(
              backgroundColor: AppTheme.klooigeldBlauw,
              onPressed: _openShop,
              child: FaIcon(FontAwesomeIcons.bagShopping, color: AppTheme.klooigeldRoze),
            )
          : null,
      body: Column(
        children: [
          ScenarioHeader(
            onBack: () async {
              // Before navigating back, ensure state is saved
              // **Only save progress if beyond step 0**
              if (_currentScenarioIndex > 0) {
                await _saveCurrentStep();
              }
              Navigator.pop(context);
            },
            klooicash: _klooicash, // Now int
            progress: progress,
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _chatMessages[index];
                        final type = msg["type"];

                        if (type == "delimiter") {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical:8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppTheme.klooigeldBlauw,
                                    thickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ScenarioMessageBubble(
                          msg: msg,
                          avatarImagePath: _avatarImagePath,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_scenarioCompleted && _showChoices)
            ScenarioChoicesList(
              choices: _scenario.steps[_currentScenarioIndex].choices,
              currentScenarioIndex: _currentScenarioIndex,
              flowersPurchased: _flowersPurchased,
              chocolatesPurchased: _chocolatesPurchased,
              optionColors: _optionColors,
              onChoiceSelected: _onChoiceSelected,
              onLockedChoice: (msg) => _showAlert(msg),
            )
          else if (!_scenarioCompleted && _showNextButton)
            Padding(
              padding: const EdgeInsets.only(bottom:28.0),
              child: ElevatedButton.icon(
                onPressed: _goToNextScenario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.klooigeldBlauw,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
                label: Text(
                  "Next",
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    color: AppTheme.white,
                  ),
                ),
              ),
            )
          else if (_scenarioCompleted)
            Padding(
              padding: const EdgeInsets.only(bottom:28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.klooigeldBlauw,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Done",
                      style: TextStyle(
                          fontFamily: AppTheme.neighbor,
                          color: AppTheme.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _replayScenario();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.klooigeldGroen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Try Again",
                      style: TextStyle(
                          fontFamily: AppTheme.neighbor,
                          color: AppTheme.white),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}
