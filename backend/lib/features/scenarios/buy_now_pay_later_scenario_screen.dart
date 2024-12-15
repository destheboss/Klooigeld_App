// lib/features/scenarios/buy_now_pay_later_scenario_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

import 'package:backend/theme/app_theme.dart';
import 'buy_now_pay_later_scenario_data.dart';
import 'models/scenario_model.dart';
import 'models/scenario_choice.dart';
import 'widgets/scenario_header.dart';
import 'widgets/scenario_message_bubble.dart';
import 'widgets/scenario_choices_list.dart';
import 'widgets/custom_dialog.dart';
import '../../../screens/(rewards)/rewards_shop_screen.dart';

/// Simple model for scenario transactions, matching the JSON structure used in the shop screen.
/// Updated to allow "Pending" date for BNPL transactions.
class TransactionRecord {
  final String description;   // e.g. "Concert Ticket", "Phone Repair", "BNPL - 700K Owed", etc.
  final int amount;           // negative for purchases, positive for income, or actual cost for BNPL
  final String date;          // stored as 'YYYY-MM-DD' or "Pending"

  TransactionRecord({
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'date': date,
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      description: json['description'],
      amount: json['amount'],
      date: json['date'],
    );
  }
}

class BuyNowPayLaterScenarioScreen extends StatefulWidget {
  const BuyNowPayLaterScenarioScreen({Key? key}) : super(key: key);

  @override
  State<BuyNowPayLaterScenarioScreen> createState() =>
      _BuyNowPayLaterScenarioScreenState();
}

class _BuyNowPayLaterScenarioScreenState extends State<BuyNowPayLaterScenarioScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late ScenarioModel _scenario;
  int _currentScenarioIndex = 0;

  //--- BALANCE & PURCHASE TRACKING ---
  int _klooicash = 0;
  int _originalBalance = 0;
  int _accumulatedDeductions = 0;

  //--- FLOW CONTROL ---
  bool _isLoading = true;
  bool _showChoices = true;
  bool _scenarioCompleted = false;   // True once we reach the final scenario step
  bool _showNextButton = false;

  bool _scenarioFirstTime = true;    // True on the first scenario completion
  bool _resumed = false;             // If user resumed partial progress
  bool _tryAgainEnabled = true;      // True if user can do the single "Try Again"
  bool _isTryAgain = false;          // True if user is currently in that single "Try Again" run
  bool _isReplay = false;            // True if scenario is in ephemeral replay mode

  int _bestScore = 0;

  //--- UI & MESSAGING ---
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatMessages = [];
  String _username = "You";
  String? _avatarImagePath;

  // Persist user choices for final feedback:
  final List<ScenarioChoice> _userChoices = [];

  //--- PURCHASE FLAGS ---
  bool _flowersPurchased = false;
  bool _chocolatesPurchased = false;

  final List<Color> _optionColors = [
    AppTheme.klooigeldRoze,
    AppTheme.klooigeldGroen,
    AppTheme.klooigeldPaars,
    AppTheme.klooigeldBlauw,
  ];

  bool _lastChoiceWasBNPL = false;

  // --- Temporary Transactions ---
  List<TransactionRecord> _temporaryTransactions = []; // NEW: Temporary list to accumulate transactions

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scenario = buildBuyNowPayLaterScenario();
    _initializeScenario();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Save final state on dispose (if mid-scenario and not fully done)
    if (!_scenarioCompleted) {
      _saveCurrentStep();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Save state if user left the app mid-scenario
      if (_currentScenarioIndex > 0 && !_scenarioCompleted) {
        _saveCurrentStep();
      }
    }
  }

  /// Ensure scenario is marked complete if user leaves at the final step.
  Future<bool> _onWillPop() async {
    debugPrint(
      "onWillPop called. "
      "currentIndex=$_currentScenarioIndex, scenarioCompleted=$_scenarioCompleted, "
      "isTryAgain=$_isTryAgain, scenarioFirstTime=$_scenarioFirstTime"
    );

    // If user is on the final step but scenarioCompleted isn't set yet, mark it now.
    if (_currentScenarioIndex == _scenario.steps.length - 1 && !_scenarioCompleted) {
      debugPrint("User is on final step, marking scenario as completed before pop.");
      setState(() {
        _scenarioCompleted = true;
      });
      await _completeScenario();
      return true;
    }
    
    // If scenario is already completed, ensure ephemeral cleanup.
    if (_scenarioCompleted) {
      debugPrint("Scenario is already marked completed. Calling _completeScenario() again.");
      await _completeScenario();
      return true;
    }

    // If not final step, just save partial progress.
    if (_currentScenarioIndex > 0 && !_scenarioCompleted) {
      debugPrint("Not final step, saving partial progress before pop.");
      _saveCurrentStep();
    }
    return true; // allow pop
  }

  // ------------------------------------------------------
  //                   INITIALIZATION
  // ------------------------------------------------------

  Future<void> _initializeScenario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve user info & best score
    _bestScore = prefs.getInt('best_score_buynowpaylater') ?? 0;
    _username = prefs.getString('username') ?? 'You';
    _avatarImagePath = prefs.getString('avatarImagePath');

    // Check main balance
    int currentMainBalance = _retrieveBalance(prefs);

    // Check if scenario was completed before
    bool completedBefore = prefs.getBool('scenario_buynowpaylater_completed') ?? false;
    _scenarioFirstTime = !completedBefore;

    // If scenario was completed, future attempts are replays by default
    if (completedBefore) {
      _isReplay = true;
      _tryAgainEnabled = false; // "Try Again" is only once, after first-time finish
      debugPrint("Scenario already completed before. Entering replay mode.");
    } else {
      _isReplay = false;
    }

    // Check if a try-again run was previously in progress
    bool previouslyInTryAgain = prefs.getBool('scenario_buynowpaylater_isTryAgain') ?? false;
    if (previouslyInTryAgain) {
      _isTryAgain = true;
      _isReplay = false; // If we’re in try-again, it’s not ephemeral
      _scenarioFirstTime = false;
      debugPrint("Resuming single Try Again attempt from SharedPreferences...");
    }

    // originalBalance
    if (!_isTryAgain && !completedBefore) {
      // First time scenario or not in try-again
      _originalBalance = currentMainBalance;
      await prefs.setInt('scenario_buynowpaylater_original_balance', _originalBalance);
      debugPrint("Setting original balance to $_originalBalance.");
    } else if (!_isTryAgain && completedBefore) {
      // If completed and not in try-again, keep originalBalance from previous run
      _originalBalance = prefs.getInt('scenario_buynowpaylater_original_balance') ?? currentMainBalance;
      debugPrint("Using original balance from previous run: $_originalBalance.");
    } else if (_isTryAgain) {
      // In try-again, keep originalBalance as is
      _originalBalance = prefs.getInt('scenario_buynowpaylater_original_balance') ?? currentMainBalance;
      debugPrint("Using original balance for Try Again: $_originalBalance.");
    }

    // ephemeral data
    _accumulatedDeductions = prefs.getInt('scenario_buynowpaylater_accumulated_deductions') ?? 0;
    _klooicash = currentMainBalance - _accumulatedDeductions;
    debugPrint("Current Klooicash: $_klooicash. Accumulated Deductions: $_accumulatedDeductions.");

    // Retrieve partial progress
    int savedStep = prefs.getInt('scenario_buynowpaylater_currentStep') ?? 0;
    List<String>? storedMessages = prefs.getStringList('scenario_buynowpaylater_chatMessages');
    List<String>? storedChoices = prefs.getStringList('scenario_buynowpaylater_userChoices');
    List<String>? storedTempTransactions = prefs.getStringList('scenario_buynowpaylater_temp_transactions'); // NEW: Retrieve temporary transactions

    // Retrieve committed transactions
    List<String>? storedCommittedTransactions = prefs.getStringList('user_transactions');

    // Load existing committed transactions
    List<TransactionRecord> committedTransactions = [];
    if (storedCommittedTransactions != null && storedCommittedTransactions.isNotEmpty) {
      committedTransactions = storedCommittedTransactions.map((e) {
        final map = jsonDecode(e) as Map<String, dynamic>;
        return TransactionRecord.fromJson(map);
      }).toList();
    }

    // Load temporary transactions
    if (storedTempTransactions != null && storedTempTransactions.isNotEmpty) {
      _temporaryTransactions = storedTempTransactions.map((e) {
        final map = jsonDecode(e) as Map<String, dynamic>;
        return TransactionRecord.fromJson(map);
      }).toList();
      debugPrint("Loaded ${_temporaryTransactions.length} temporary transactions.");
    }

    // If partial progress found, ask to resume or restart
    if (!_isReplay && savedStep > 0 && storedMessages != null && storedMessages.isNotEmpty) {
      bool? resume = await _askResumeOrRestart();
      if (resume == true) {
        // Resume partial progress
        _currentScenarioIndex = savedStep;
        _resumed = true;
        debugPrint("Resuming scenario from step $_currentScenarioIndex.");

        // Restore chat messages
        _chatMessages = storedMessages.map((m) => jsonDecode(m) as Map<String, dynamic>).toList();

        // Restore user choices
        if (storedChoices != null && storedChoices.isNotEmpty) {
          _userChoices.clear();
          for (var choiceJson in storedChoices) {
            final rawMap = jsonDecode(choiceJson) as Map<String, dynamic>;
            _userChoices.add(ScenarioChoice(
              text: rawMap['text'] ?? '',
              dialogueText: rawMap['dialogueText'] ?? '',
              outcome: rawMap['outcome'] ?? '',
              kChange: rawMap['kChange'] ?? 0,
            ));
          }
        }

        // Restore temporary transactions
        // Already loaded above
      } else {
        // Full reset scenario from scratch
        _currentScenarioIndex = 0;
        _chatMessages.clear();
        _userChoices.clear();
        _accumulatedDeductions = 0;
        _klooicash = currentMainBalance;
        _showNextButton = false;
        _showChoices = true;
        await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', 0);
        await _clearSavedState();
        debugPrint("Restarting scenario from scratch.");
      }
    } else {
      // If we didn’t resume partial progress
      if (_currentScenarioIndex == 0 || _isReplay) {
        _chatMessages.clear();
        _userChoices.clear();
        debugPrint("Starting new scenario run.");
      } else if (storedMessages != null) {
        _chatMessages =
            storedMessages.map((m) => jsonDecode(m) as Map<String, dynamic>).toList();
      }
      if (storedChoices != null && storedChoices.isNotEmpty && !_isReplay) {
        _userChoices.clear();
        for (var choiceJson in storedChoices) {
          final rawMap = jsonDecode(choiceJson) as Map<String, dynamic>;
          _userChoices.add(ScenarioChoice(
            text: rawMap['text'] ?? '',
            dialogueText: rawMap['dialogueText'] ?? '',
            outcome: rawMap['outcome'] ?? '',
            kChange: rawMap['kChange'] ?? 0,
          ));
        }
      }
    }

    // Load purchase flags
    _flowersPurchased = prefs.getBool('scenario_buynowpaylater_flowersPurchased') ?? false;
    _chocolatesPurchased = prefs.getBool('scenario_buynowpaylater_chocolatesPurchased') ?? false;
    // Reflect permanent shop items
    List<String> purchasedItems = prefs.getStringList('purchasedItems') ?? [];
    if (purchasedItems.contains('201')) _flowersPurchased = true;
    if (purchasedItems.contains('202')) _chocolatesPurchased = true;
    debugPrint("Flowers purchased: $_flowersPurchased. Chocolates purchased: $_chocolatesPurchased.");

    // Restore UI flags
    _showNextButton = prefs.getBool('scenario_buynowpaylater_showNextButton') ?? false;
    _showChoices = prefs.getBool('scenario_buynowpaylater_showChoices') ?? true;
    _lastChoiceWasBNPL = prefs.getBool('scenario_buynowpaylater_lastChoiceWasBNPL') ?? false;

    setState(() {
      _isLoading = false;
    });

    // If last choice was BNPL, show the reminder once the UI builds
    if (_lastChoiceWasBNPL) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showBNPLReminder());
    }

    // If chat is empty, add the first NPC message
    if (_chatMessages.isEmpty) {
      _addNPCMessage(
        _scenario.steps[_currentScenarioIndex].npcMessage,
        _scenario.steps[_currentScenarioIndex].npcName,
        animate: false,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
  }

  Future<bool?> _askResumeOrRestart() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        icon: FontAwesomeIcons.questionCircle,
        title: "Resume Scenario?",
        content: "You left this scenario before. Resume or restart?",
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klooigeldRozeAlt,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Restart", style: TextStyle(fontSize: 16, color: AppTheme.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klooigeldBlauw,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Resume", style: TextStyle(fontSize: 16, color: AppTheme.white)),
                ),
              ),
            ],
          ),
        ],
        closeValue: null,
      ),
    );
  }

  // ------------------------------------------------------
  //               CLEARING SAVED STATE
  // ------------------------------------------------------

  Future<void> _clearSavedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('scenario_buynowpaylater_currentStep');
    await prefs.remove('scenario_buynowpaylater_chatMessages');
    await prefs.remove('scenario_buynowpaylater_accumulated_deductions');
    await prefs.remove('scenario_buynowpaylater_tempBalance');
    await prefs.remove('scenario_buynowpaylater_showNextButton');
    await prefs.remove('scenario_buynowpaylater_showChoices');
    await prefs.remove('scenario_buynowpaylater_lastChoiceWasBNPL');
    await prefs.remove('scenario_buynowpaylater_userChoices');
    // We'll also remove the isTryAgain flag if we fully reset scenario:
    await prefs.remove('scenario_buynowpaylater_isTryAgain');
    // NEW: Remove temporary transactions
    await prefs.remove('scenario_buynowpaylater_temp_transactions');
    debugPrint("Cleared saved scenario state.");

    // Also clear in-memory temporary transactions
    _temporaryTransactions.clear();
    debugPrint("Cleared in-memory temporary transactions.");
  }

  /// This forcibly resets everything including original_balance.
  Future<void> _clearAllScenarioData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _clearSavedState();
    await prefs.remove('scenario_buynowpaylater_original_balance');
    // Do not remove "scenario_buynowpaylater_completed" or "best_score_buynowpaylater"
    // unless you truly want to reset scenario completion state in the system.
    debugPrint("Cleared all scenario data including original balance.");
  }

  // ------------------------------------------------------
  //        BALANCE & SCENARIO STATE SAVING
  // ------------------------------------------------------

  int _retrieveBalance(SharedPreferences prefs) {
    final balance = prefs.get('klooicash');
    if (balance is int) return balance;
    if (balance is double) return balance.toInt();
    return 500; // fallback
  }

  Future<void> _saveBalanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_resumed && !_isTryAgain) {
      // Only set original balance if not resuming partial progress and not in Try Again
      await prefs.setInt('scenario_buynowpaylater_original_balance', _originalBalance);
    }
    await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', _accumulatedDeductions);
    await prefs.setInt('scenario_buynowpaylater_tempBalance', _klooicash);
    debugPrint("Saved balance state. Klooicash: $_klooicash, Deductions: $_accumulatedDeductions.");
  }

  Future<void> _saveCurrentStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_currentScenarioIndex < 0) return;

    await prefs.setInt('scenario_buynowpaylater_currentStep', _currentScenarioIndex);

    List<String> serializedMessages = _chatMessages.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList('scenario_buynowpaylater_chatMessages', serializedMessages);

    // Persist user choices so final feedback is accurate
    List<String> serializedChoices = _userChoices.map((choice) {
      return jsonEncode({
        'text': choice.text,
        'dialogueText': choice.dialogueText,
        'outcome': choice.outcome,
        'kChange': choice.kChange,
      });
    }).toList();
    await prefs.setStringList('scenario_buynowpaylater_userChoices', serializedChoices);

    await prefs.setBool('scenario_buynowpaylater_showNextButton', _showNextButton);
    await prefs.setBool('scenario_buynowpaylater_showChoices', _showChoices);
    await prefs.setBool('scenario_buynowpaylater_lastChoiceWasBNPL', _lastChoiceWasBNPL);
    await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', _accumulatedDeductions);

    // Also persist if we are in Try Again:
    await prefs.setBool('scenario_buynowpaylater_isTryAgain', _isTryAgain);

    // NEW: Persist temporary transactions
    List<String> serializedTempTransactions = _temporaryTransactions.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList('scenario_buynowpaylater_temp_transactions', serializedTempTransactions);

    debugPrint("Saved current scenario step: $_currentScenarioIndex.");
  }

  // ------------------------------------------------------
  //               TRANSACTION LOGGING
  // ------------------------------------------------------

  /// Accumulates transactions during the scenario run.
  /// These are only committed to persistent storage upon scenario completion.
  void _addTemporaryTransaction(String description, int amount, {bool isBNPL = false}) {
    String dateString = isBNPL ? "Pending" : _getTodayDateString();
    final newTx = TransactionRecord(
      description: description,
      amount: amount,
      date: dateString,
    );
    _temporaryTransactions.insert(0, newTx);
    debugPrint("Added temporary transaction: $description, Amount: $amount, Date: $dateString.");
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// Commit temporary transactions to persistent storage
  Future<void> _commitTransactions() async {
    if (_temporaryTransactions.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('user_transactions') ?? [];
    final List<TransactionRecord> existing = rawList.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return TransactionRecord.fromJson(map);
    }).toList();

    // Add all temporary transactions
    existing.insertAll(0, _temporaryTransactions);

    // Persist
    final newRawList = existing.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList('user_transactions', newRawList);
    debugPrint("Committed ${_temporaryTransactions.length} transactions to persistent storage.");

    // Clear temporary transactions
    _temporaryTransactions.clear();

    // Also remove temporary transactions from SharedPreferences
    await prefs.remove('scenario_buynowpaylater_temp_transactions');
    debugPrint("Cleared temporary transactions from SharedPreferences.");
  }

  /// Only log permanent transactions if this run is the first scenario run or the single "Try Again".
  /// If _isReplay is true, scenario changes are ephemeral and should not be added to user_transactions.
  /// NEW: BNPL transactions include actual cost with descriptive title
  Future<void> _logTransaction(String description, int amount, {bool isBNPL = false}) async {
    if (_isReplay) {
      debugPrint("Replay mode: Skipping transaction logging for $description.");
      return;
    }

    if (_isTryAgain || _scenarioFirstTime) {
      _addTemporaryTransaction(description, amount, isBNPL: isBNPL);
    }
  }

  // ------------------------------------------------------
  //               SCENARIO FLOW
  // ------------------------------------------------------

  Future<void> _onChoiceSelected(ScenarioChoice choice) async {
    setState(() {
      _showChoices = false;
      _showNextButton = true;
    });

    // Show user’s chosen line
    _addUserMessage(choice.dialogueText);

    // Only apply kChange if scenario is truly the first or the single "try again"
    int actualChange = (_scenarioFirstTime || _isTryAgain) ? choice.kChange : 0;

    // Decide if BNPL is used (those scenario choices contain "Klaro" text)
    bool isBNPL = choice.text.toLowerCase().contains("klaro");

    // Generate a descriptive transaction title (instead of the choice text)
    /// NEW: More descriptive titles
    String? transactionTitle;
    if (choice.text.contains("Pay 20K")) {
      transactionTitle = isBNPL ? "Concert Ticket (Klaro)" : "Concert Ticket";
    } else if (choice.text.contains("Pay 70K")) {
      transactionTitle = "Phone Repair";
    } else if (choice.text.contains("new phone via Klaro")) {
      transactionTitle = "New Phone (Klaro)";
    } else if (choice.text.contains("flowers")) {
      transactionTitle = "Flowers for Grandma";
    } else if (choice.text.contains("chocolates")) {
      transactionTitle = "Chocolates for Grandma";
    }

    /// NEW: Avoid double-logging shop items:
    /// If flowersPurchased or chocolatesPurchased is already true,
    /// do not add a second scenario transaction for the same item.
    bool skipIfOverlapPurchase = false;
    if (transactionTitle == "Flowers for Grandma" && _flowersPurchased) {
      skipIfOverlapPurchase = true;
      debugPrint("Skipping transaction logging for Flowers as they are already purchased from the shop.");
    } else if (transactionTitle == "Chocolates for Grandma" && _chocolatesPurchased) {
      skipIfOverlapPurchase = true;
      debugPrint("Skipping transaction logging for Chocolates as they are already purchased from the shop.");
    }

    // BNPL => record the actual cost with descriptive title
    // Immediate pay => record normal transaction with negative amount
    if (transactionTitle != null && !skipIfOverlapPurchase) {
      if (isBNPL) {
        /// BNPL transaction includes the actual cost
        if (transactionTitle.contains("Concert Ticket")) {
          await _logTransaction("Concert Ticket (Klaro)", -20, isBNPL: true);
        } else if (transactionTitle.contains("New Phone (Klaro)")) {
          await _logTransaction("New Phone (Klaro)", -700, isBNPL: true);
        }
      } else {
        /// Regular transaction
        await _logTransaction(transactionTitle, actualChange);
      }
    }

    // Negative => user paying for something; positive => user gain
    if (actualChange < 0) {
      _accumulatedDeductions += -actualChange;
      debugPrint("Applied deduction of ${-actualChange}. Total deductions: $_accumulatedDeductions.");
    } else if (actualChange > 0) {
      _klooicash += actualChange;
      debugPrint("Applied gain of $actualChange. New Klooicash balance: $_klooicash.");
      /// If this is a direct positive scenario choice (like grandma reward),
      /// log that as well, provided it's not overlapping shop transaction.
      if (transactionTitle != null && !skipIfOverlapPurchase) {
        await _logTransaction("Grandma Reward", actualChange);
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int mainBalance = _retrieveBalance(prefs);
    _klooicash = mainBalance - _accumulatedDeductions;
    debugPrint("Recomputed Klooicash: $_klooicash.");

    // BNPL reminder
    _lastChoiceWasBNPL = isBNPL;

    // Show outcome message (+/-)
    _addOutcomeMessage(choice.outcome, choice.kChange);

    // Track user choice
    _userChoices.add(choice);

    // Additional synergy logic: Grandma synergy (30K or 15K)
    // The code below is specifically awarding the grandma reward:
    //  - Flowers => +30K
    //  - Chocolates => +15K
    if ((_scenarioFirstTime || _isTryAgain)) {
      if (choice.text.contains("flowers")) {
        _klooicash += 30;
          await _logTransaction("Grandma Reward", 30);
          debugPrint("Grandma rewarded 30K for flowers.");
      } else if (choice.text.contains("chocolates")) {
        _klooicash += 15;
          await _logTransaction("Grandma Reward", 15);
          debugPrint("Grandma rewarded 15K for chocolates.");
      }
    }

    await _saveBalanceState();
    if (_currentScenarioIndex > 0) {
      await _saveCurrentStep();
    }
  }

  Future<void> _goToNextScenario() async {
    setState(() => _showNextButton = false);

    if (_lastChoiceWasBNPL) {
      _showBNPLReminder();
      return;
    }

    if (_currentScenarioIndex < _scenario.steps.length - 1) {
      _currentScenarioIndex++;
      _addNPCMessage(
        _scenario.steps[_currentScenarioIndex].npcMessage,
        _scenario.steps[_currentScenarioIndex].npcName,
      );
      setState(() => _showChoices = true);
      await _saveCurrentStep();
    } else {
      // Reached final step
      _scenarioCompleted = true;
      setState(() {});
      _showEndScenarioFeedbackInChat();
      debugPrint("Reached end of scenario. Preparing to commit transactions.");
      await _commitTransactions(); // NEW: Commit all transactions at the end
    }
  }

  Future<void> _showBNPLReminder() async {
    String reminder = "Keep track of what you owe Klaro!";
    if (_userChoices.any((c) => c.text.contains("Concert Ticket (Klaro)"))) {
      reminder = "Reminder: You need to pay Klaro for the concert ticket soon!";
    } else if (_userChoices.any((c) => c.text.contains("New Phone (Klaro)"))) {
      reminder = "Reminder: Your phone bill via Klaro (700K) is due later!";
    }

    debugPrint("Showing BNPL reminder: $reminder");

    bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => CustomDialog(
        icon: FontAwesomeIcons.moneyCheckAlt,
        title: "Klaro Reminder",
        content: reminder,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.klooigeldBlauw,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("OK", style: TextStyle(fontSize: 16, color: AppTheme.white)),
          ),
        ],
        closeValue: true,
      ),
    );

    // reset BNPL flag
    if (result == true || result == null) {
      setState(() => _lastChoiceWasBNPL = false);
      await _saveCurrentStep();
      _goToNextScenario();
    }
  }

  // ------------------------------------------------------
  //         COMPLETION, TRY AGAIN, REPLAY
  // ------------------------------------------------------

  Future<void> _completeScenario() async {
    debugPrint("Completing scenario... isTryAgain=$_isTryAgain, scenarioFirstTime=$_scenarioFirstTime");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_scenarioFirstTime && !_isTryAgain) {
      // first real completion
      debugPrint("First real completion. Mark scenario as done, allow Try Again once.");
      if (_klooicash > 0) {
        int unlockedIndex = prefs.getInt('unlockedLevelIndex') ?? 0;
        if (unlockedIndex < 1) {
          await prefs.setInt('unlockedLevelIndex', 1);
          debugPrint("Unlocked level index updated to 1.");
        }
      }
      if (_klooicash > _bestScore) {
        _bestScore = _klooicash;
        await prefs.setInt('best_score_buynowpaylater', _bestScore);
        debugPrint("Best score updated to $_bestScore.");
      }

      await prefs.setBool('scenario_buynowpaylater_completed', true);
      debugPrint("Marked scenario as completed.");

      // Apply final Klooicash to main
      await prefs.setInt('klooicash', _klooicash);
      debugPrint("Updated main Klooicash balance to $_klooicash.");

      // Clear ephemeral
      await _clearSavedState();

      // The user is now allowed one "Try Again"
      _scenarioFirstTime = false;
      _tryAgainEnabled = true;
      _isReplay = false;
    } 
    else if (_isTryAgain) {
      // single tryAgain attempt
      debugPrint("Completing single 'Try Again' attempt. Applying changes to main balance.");

      // Update the main balance to _klooicash
      await prefs.setInt('klooicash', _klooicash);
      debugPrint("Updated main Klooicash balance to $_klooicash.");

      // Unlock the next level after a successful Try Again attempt
      int unlockedIndex = prefs.getInt('unlockedLevelIndex') ?? 0;
      if (unlockedIndex < 1) { // Assuming there's only one level to unlock
        unlockedIndex += 1;
        await prefs.setInt('unlockedLevelIndex', unlockedIndex);
        debugPrint("Unlocked next level index updated to $unlockedIndex.");
      }

      await prefs.setBool('scenario_buynowpaylater_completed', true);

      // Clear ephemeral
      await _clearSavedState();
      await prefs.setBool('scenario_buynowpaylater_isTryAgain', false);
      debugPrint("Cleared try-again state.");

      // The user cannot try again again
      _tryAgainEnabled = false; 
      _isTryAgain = false;
      _scenarioFirstTime = false; 
      _isReplay = true; // future attempts become replays
    }
    else {
      // Scenario replay or subsequent attempt completion. Ephemeral revert.
      debugPrint("Scenario replay completion. Ephemeral revert, scenario remains completed in prefs.");
      int currentMainBalance = prefs.getInt('klooicash') ?? _originalBalance;
      if (currentMainBalance != _originalBalance) {
        await prefs.setInt('klooicash', _originalBalance);
        debugPrint("Reverted main balance from $currentMainBalance to $_originalBalance.");
      }
      _klooicash = _originalBalance;

      await prefs.remove('scenario_buynowpaylater_currentStep');
      await prefs.remove('scenario_buynowpaylater_showNextButton');
      await prefs.remove('scenario_buynowpaylater_showChoices');
      await prefs.remove('scenario_buynowpaylater_lastChoiceWasBNPL');
      await prefs.remove('scenario_buynowpaylater_userChoices');
      debugPrint("Removed replay scenario state.");

      _accumulatedDeductions = 0;
      await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', 0);
      debugPrint("Reset accumulated deductions to $_accumulatedDeductions.");

      // revert ephemeral purchases
      List<String> permanentlyPurchased = prefs.getStringList('purchasedItems') ?? [];
      if (!permanentlyPurchased.contains('201')) {
        _flowersPurchased = false;
        await prefs.setBool('scenario_buynowpaylater_flowersPurchased', false);
        debugPrint("Reverted flowersPurchased to $_flowersPurchased.");
      }
      if (!permanentlyPurchased.contains('202')) {
        _chocolatesPurchased = false;
        await prefs.setBool('scenario_buynowpaylater_chocolatesPurchased', false);
        debugPrint("Reverted chocolatesPurchased to $_chocolatesPurchased.");
      }
    }
  }

  /// The single "Try Again" attempt.
  Future<void> _tryAgainScenario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the current main balance to use as the starting point for Try Again
    int currentMainBalance = _retrieveBalance(prefs);
    _klooicash = currentMainBalance;

    // Clear ephemeral scenario states
    await _clearSavedState();

    // Persist that we are now in a single "try again" run
    await prefs.setBool('scenario_buynowpaylater_isTryAgain', true);
    debugPrint("Marked scenario as Try Again.");

    setState(() {
      _currentScenarioIndex = 0;
      _showChoices = true;
      _scenarioCompleted = false;
      _chatMessages.clear();
      _userChoices.clear();
      _accumulatedDeductions = 0;

      _isTryAgain = true;
      _isReplay = false;

      // Clear in-memory temporary transactions to ensure isolation
      _temporaryTransactions.clear();
      debugPrint("Cleared in-memory temporary transactions for Try Again.");
    });

    _addNPCMessage(
      _scenario.steps[_currentScenarioIndex].npcMessage,
      _scenario.steps[_currentScenarioIndex].npcName,
      animate: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
    debugPrint("Started Try Again scenario.");
  }

  Future<void> _replayScenario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _clearSavedState();
    debugPrint("Cleared saved state for replay.");

    setState(() {
      _currentScenarioIndex = 0;
      _showChoices = true;
      _scenarioCompleted = false;
      _chatMessages.clear();
      _userChoices.clear();
      _klooicash = _originalBalance;
      _accumulatedDeductions = 0;
      _showNextButton = false;
      _lastChoiceWasBNPL = false;

      _scenarioFirstTime = false;
      _isTryAgain = false;
      _isReplay = true;

      // Clear in-memory temporary transactions to ensure isolation
      _temporaryTransactions.clear();
      debugPrint("Cleared in-memory temporary transactions for Replay.");
    });

    _addNPCMessage(
      _scenario.steps[_currentScenarioIndex].npcMessage,
      _scenario.steps[_currentScenarioIndex].npcName,
      animate: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
    debugPrint("Started Replay scenario.");
  }

  // ------------------------------------------------------
  //           FINAL FEEDBACK & MESSAGING
  // ------------------------------------------------------

  void _showEndScenarioFeedbackInChat() {
    _addDelimiter();
    String feedback = _analyzeUserChoices();
    String finalMessage;

    if (_scenarioFirstTime && !_isTryAgain) {
      // first real completion
      if (_klooicash > 0) {
        finalMessage = "You finished with some money left. Good job!\n\n"
            "You have a one-time Try Again option if you want a different path.\n\n"
            "$feedback";
      } else {
        finalMessage = "You ended up with no spare money. Some choices were costly.\n\n"
            "You have a one-time Try Again. Good luck!\n\n"
            "$feedback";
      }
    } else if (_isTryAgain) {
      // single tryAgain attempt
      if (_klooicash > 0) {
        finalMessage = "Try Again attempt ended with leftover money. Your main balance has been updated.\n\n$feedback";
      } else {
        finalMessage = "Try Again attempt ended with no leftover money. Your main balance has been updated.\n\n$feedback";
      }
    } else {
      // Replay
      if (_klooicash > 0) {
        finalMessage = "Replay ended with leftover money, but it reverts to original.\n\n$feedback";
      } else {
        finalMessage = "Replay ended with no leftover money, your balance reverts.\n\n$feedback";
      }
    }

    _addFinalFeedbackMessage(finalMessage);
    _saveCurrentStep();
    debugPrint("Displayed final feedback in chat.");
  }

  String _analyzeUserChoices() {
    if (_userChoices.isEmpty) {
      return "";
    }

    StringBuffer analysis = StringBuffer("Let’s look at your big choices:\n\n");
    if (_userChoices.length > 1) {
      var concertChoice = _userChoices[1].text;
      if (concertChoice.contains("Pay 20K now")) {
        analysis.writeln("- Concert: Paid 20K upfront. No future debt.");
      } else if (concertChoice.contains("Concert Ticket (Klaro)")) {
        analysis.writeln("- Concert: BNPL, short-term relief but future debt looming.");
      }
    }

    if (_userChoices.length > 3) {
      var phoneChoice = _userChoices[3].text;
      if (phoneChoice.contains("Phone Repair")) {
        analysis.writeln("- Phone: Paid 70K now, no big debt later.");
      } else if (phoneChoice.contains("New Phone (Klaro)")) {
        analysis.writeln("- Phone: BNPL for a 700K phone, major debt risk later.");
      } else if (phoneChoice.contains("Keep it cracked")) {
        analysis.writeln("- Phone: No immediate cost, but ongoing risk of a broken phone fiasco.");
      }
    }

    if (_userChoices.length > 5) {
      var grandmaChoice = _userChoices[5].text;
      if (grandmaChoice.contains("flowers")) {
        analysis.writeln("- Grandma: Spent 10K, gained 30K. Excellent net gain.");
      } else if (grandmaChoice.contains("chocolates")) {
        analysis.writeln("- Grandma: Spent 5K, gained 15K. Smaller but still positive net gain.");
      }
    }

    analysis.writeln("\nBNPL can give short-term relief but watch for big future debts!");
    return analysis.toString();
  }

  // ------------------------------------------------------
  //           UI & MESSAGING HELPERS
  // ------------------------------------------------------

  void _addNPCMessage(String message, String speakerName, {bool animate = true}) {
    _chatMessages.add({
      "type": "npc",
      "speaker": speakerName,
      "message": message,
    });
    setState(() {});
    if (animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
    }
    debugPrint("Added NPC message: $message");
  }

  void _addUserMessage(String message) {
    _chatMessages.add({
      "type": "user",
      "speaker": _username,
      "message": message,
    });
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
    debugPrint("Added User message: $message");
  }

  void _addOutcomeMessage(String outcome, int kChange) {
    String feedback = "";
    if ((_scenarioFirstTime || _isTryAgain) && kChange != 0) {
      feedback = kChange > 0 ? " (+$kChange)" : " ($kChange)";
    }
    String finalMessage = outcome + feedback;

    _chatMessages.add({
      "type": "outcome",
      "message": finalMessage,
    });
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
    debugPrint("Added outcome message: $finalMessage");
  }

  void _addDelimiter() {
    _chatMessages.add({"type": "delimiter"});
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
    debugPrint("Added delimiter in chat.");
  }

  void _addFinalFeedbackMessage(String feedback) {
    _chatMessages.add({"type": "outcome", "message": feedback});
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
    debugPrint("Added final feedback message: $feedback");
  }

  void _scrollToBottomWithAnimation() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      debugPrint("Scrolled to bottom of chat.");
    }
  }

  void _showAlert(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: AppTheme.neighbor, color: Colors.white)),
      backgroundColor: AppTheme.klooigeldBlauw,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
    debugPrint("Displayed alert: $message");
  }

  bool _shouldShowShop() {
    // Show shop if user is at step 5 choosing grandma's gift
    return _currentScenarioIndex == 5 && !_scenarioCompleted && _showChoices;
  }

  Future<void> _openShop() async {
    // Pass ephemeral flag if scenario is a replay
    final purchasedNow = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        return RewardsShopScreen(
          isModal: true,
          isEphemeral: _isReplay,
          initialCategoryId: 4, // Scenario-limited shop
          initialBalance: _klooicash,
          onClose: () {
            Navigator.pop(context, <int>{});
          },
          onKlooicashUpdate: (newBalance) {
            setState(() {
              _klooicash = newBalance;
            });
            debugPrint("Updated Klooicash from shop: $_klooicash.");
          },
        );
      },
    ) ?? <int>{};

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (purchasedNow.contains(201)) {
      _flowersPurchased = true;
      if (!_isReplay) {
        List<String> permanent = prefs.getStringList('purchasedItems') ?? [];
        if (!permanent.contains('201')) {
          permanent.add('201');
          await prefs.setStringList('purchasedItems', permanent);
          debugPrint("Flowers purchased from shop.");
        }
      }
    }
    if (purchasedNow.contains(202)) {
      _chocolatesPurchased = true;
      if (!_isReplay) {
        List<String> permanent = prefs.getStringList('purchasedItems') ?? [];
        if (!permanent.contains('202')) {
          permanent.add('202');
          await prefs.setStringList('purchasedItems', permanent);
          debugPrint("Chocolates purchased from shop.");
        }
      }
    }

    await _saveBalanceState();

    // Save ephemeral flags for scenario
    await prefs.setBool('scenario_buynowpaylater_flowersPurchased', _flowersPurchased);
    await prefs.setBool('scenario_buynowpaylater_chocolatesPurchased', _chocolatesPurchased);

    setState(() {});
  }

  // ------------------------------------------------------
  //                  BUILD METHOD
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalSteps = _scenario.steps.length;
    final progress = (_currentScenarioIndex + (_showChoices ? 0 : 1)) / totalSteps;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: _shouldShowShop()
            ? FloatingActionButton(
                backgroundColor: AppTheme.klooigeldBlauw,
                onPressed: _openShop,
                child: const FaIcon(FontAwesomeIcons.bagShopping, color: AppTheme.klooigeldRoze),
              )
            : null,
        body: Column(
          children: [
            ScenarioHeader(
              onBack: () async {
                if (_scenarioCompleted) {
                  await _completeScenario();
                } else if (_currentScenarioIndex > 0) {
                  await _saveCurrentStep();
                }
                Navigator.pop(context);
                debugPrint("User navigated back from scenario screen.");
              },
              klooicash: _klooicash,
              progress: progress,
            ),
            const SizedBox(height: 10),
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
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                padding: const EdgeInsets.only(bottom: 28.0),
                child: ElevatedButton.icon(
                  onPressed: _goToNextScenario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klooigeldBlauw,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
                  label: const Text(
                    "Next",
                    style: TextStyle(fontFamily: AppTheme.neighbor, color: AppTheme.white),
                  ),
                ),
              )
            else if (_scenarioCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // DONE always present
                    ElevatedButton(
                      onPressed: () async {
                        await _completeScenario();
                        Navigator.pop(context, true);
                        debugPrint("User pressed Done button.");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.klooigeldBlauw,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(fontFamily: AppTheme.neighbor, color: AppTheme.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_scenarioFirstTime && !_isTryAgain && _tryAgainEnabled) 
                      // After first-ever completion, show Try Again button once
                      ElevatedButton(
                        onPressed: _tryAgainScenario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.klooigeldGroen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Try Again",
                          style: TextStyle(fontFamily: AppTheme.neighbor, color: AppTheme.white),
                        ),
                      )
                    else if (_isTryAgain)
                      // If user is in the single try again run, final screen => only Done
                      const SizedBox()
                    else
                      // All other cases => Replay
                      ElevatedButton(
                        onPressed: _replayScenario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.klooigeldGroen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Replay",
                          style: TextStyle(fontFamily: AppTheme.neighbor, color: AppTheme.white),
                        ),
                      ),
                  ],
                ),
              )
            else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
