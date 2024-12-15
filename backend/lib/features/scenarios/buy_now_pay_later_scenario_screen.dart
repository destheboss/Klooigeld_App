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

  bool _scenarioFirstTime = true;    // True on first-ever completion
  bool _resumed = false;             // If user resumed partial progress (first attempt)
  bool _tryAgainEnabled = true;      // True if user can do the single "Try Again"
  bool _isTryAgain = false;          // True if the user is currently in that single "Try Again" run
  bool _isReplay = false;            // True if scenario is in ephemeral replay mode (after try again is consumed)

  int _bestScore = 0;

  //--- UI & MESSAGING ---
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatMessages = [];
  String _username = "You";
  String? _avatarImagePath;

  // Persist user choices for final feedback after resume:
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
  /// This addresses the back button / system gesture exit at final step.
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
      _tryAgainEnabled = false;  // "Try Again" is available only once, after first-time finish
    } else {
      _isReplay = false;
    }

    // Check if a try-again run was previously in progress:
    bool previouslyInTryAgain = prefs.getBool('scenario_buynowpaylater_isTryAgain') ?? false;
    if (previouslyInTryAgain) {
      // If the user was in the middle of Try Again, resume that state:
      _isTryAgain = true;
      _isReplay = false;
      _scenarioFirstTime = false; // Because scenario must have been completed once
      debugPrint("Resuming single Try Again attempt from SharedPreferences...");
    }

    // originalBalance
    if (!completedBefore) {
      // If not completed before, set original balance from current main balance
      _originalBalance = currentMainBalance;
      await prefs.setInt('scenario_buynowpaylater_original_balance', _originalBalance);
    } else {
      // If completed, keep originalBalance stored from first run
      _originalBalance = prefs.getInt('scenario_buynowpaylater_original_balance') ?? currentMainBalance;
    }

    // ephemeral data
    _accumulatedDeductions = prefs.getInt('scenario_buynowpaylater_accumulated_deductions') ?? 0;
    _klooicash = currentMainBalance - _accumulatedDeductions;

    // Retrieve partial progress
    int savedStep = prefs.getInt('scenario_buynowpaylater_currentStep') ?? 0;
    List<String>? storedMessages = prefs.getStringList('scenario_buynowpaylater_chatMessages');
    List<String>? storedChoices = prefs.getStringList('scenario_buynowpaylater_userChoices');

    // If not replay and partial progress found, ask to resume or restart
    if (!_isReplay && savedStep > 0 && storedMessages != null && storedMessages.isNotEmpty) {
      bool? resume = await _askResumeOrRestart();
      if (resume == true) {
        // Resume partial progress
        _currentScenarioIndex = savedStep;
        _resumed = true;
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
      }
    } else {
      // If we didn’t resume partial progress (fresh start / replay),
      // we’ll just rely on the current scenario index which by default is 0.
      // Clear chat if scenario is new or replay:
      if (_currentScenarioIndex == 0 || _isReplay) {
        _chatMessages.clear();
        _userChoices.clear();
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
  }

  /// This forcibly resets everything including original_balance, 
  /// making it appear truly new.
  Future<void> _clearAllScenarioData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _clearSavedState();
    await prefs.remove('scenario_buynowpaylater_original_balance');
    // Do not remove "scenario_buynowpaylater_completed" or "best_score_buynowpaylater"
    // unless you truly want to reset scenario completion state in the system.
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
    if (!_resumed) {
      // Only set original balance if not resuming partial progress
      await prefs.setInt('scenario_buynowpaylater_original_balance', _originalBalance);
    }
    await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', _accumulatedDeductions);
    await prefs.setInt('scenario_buynowpaylater_tempBalance', _klooicash);
  }

  Future<void> _saveCurrentStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If the user never proceeded to any step, no need to store
    if (_currentScenarioIndex < 0) return;

    await prefs.setInt('scenario_buynowpaylater_currentStep', _currentScenarioIndex);

    List<String> serializedMessages = _chatMessages.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList('scenario_buynowpaylater_chatMessages', serializedMessages);

    // Persist user choices so final feedback is accurate upon resume
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
    // (In replay mode, actualChange = 0).
    int actualChange = (_scenarioFirstTime || _isTryAgain) ? choice.kChange : 0;

    if (actualChange < 0) {
      _accumulatedDeductions += -actualChange;
    } else {
      _klooicash += actualChange;
    }

    // Recompute ephemeral scenario balance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int mainBalance = _retrieveBalance(prefs);
    _klooicash = mainBalance - _accumulatedDeductions;

    // BNPL reminder
    _lastChoiceWasBNPL = choice.text.contains("Klaro");

    // Show outcome message
    _addOutcomeMessage(choice.outcome, choice.kChange);

    // Track user choices
    _userChoices.add(choice);

    // Grandma synergy only if first attempt OR single tryAgain
    if ((_scenarioFirstTime || _isTryAgain) && choice.text.contains("flowers")) {
      _klooicash += 30;
    } else if ((_scenarioFirstTime || _isTryAgain) && choice.text.contains("chocolates")) {
      _klooicash += 15;
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
    }
  }

  Future<void> _showBNPLReminder() async {
    String reminder = "Keep track of what you owe Klaro!";
    if (_userChoices.any((c) => c.text.contains("ticket via Klaro"))) {
      reminder = "Reminder: You need to pay Klaro for the concert ticket soon!";
    } else if (_userChoices.any((c) => c.text.contains("new phone via Klaro"))) {
      reminder = "Reminder: Your phone bill via Klaro (700K) is due later!";
    }

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

  /// Called when the user taps "Done" on the final screen 
  /// or if the user navigates away after the final step.
  Future<void> _completeScenario() async {
    debugPrint("Completing scenario... isTryAgain=$_isTryAgain, scenarioFirstTime=$_scenarioFirstTime");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If truly the first scenario completion (not isTryAgain)
    if (_scenarioFirstTime && !_isTryAgain) {
      debugPrint("First real completion. Mark scenario as done, allow Try Again once.");
      if (_klooicash > 0) {
        int unlockedIndex = prefs.getInt('unlockedLevelIndex') ?? 0;
        if (unlockedIndex < 1) {
          await prefs.setInt('unlockedLevelIndex', 1);
        }
      }
      if (_klooicash > _bestScore) {
        _bestScore = _klooicash;
        await prefs.setInt('best_score_buynowpaylater', _bestScore);
      }

      // Mark scenario done
      await prefs.setBool('scenario_buynowpaylater_completed', true);

      // Apply final Klooicash to main
      await prefs.setInt('klooicash', _klooicash);

      // Clear ephemeral
      await _clearSavedState();

      // The user is now allowed one "Try Again"
      _scenarioFirstTime = false;
      _tryAgainEnabled = true;
      _isReplay = false;
    } 
    // If the user is currently on their single "Try Again" run
    else if (_isTryAgain) {
      debugPrint("Completing single 'Try Again' attempt. Marking scenario complete again, ephemeral revert.");
      // Make sure the scenario is recognized as complete:
      await prefs.setBool('scenario_buynowpaylater_completed', true);

      // End the try-again attempt
      // Revert ephemeral changes made only in "Try Again"
      int currentMainBalance = prefs.getInt('klooicash') ?? _originalBalance;
      if (currentMainBalance != _originalBalance) {
        await prefs.setInt('klooicash', _originalBalance);
      }
      _klooicash = _originalBalance;

      _accumulatedDeductions = 0;
      await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', 0);

      // revert ephemeral purchases made during "try again"
      List<String> permanentlyPurchased = prefs.getStringList('purchasedItems') ?? [];
      if (!permanentlyPurchased.contains('201')) {
        _flowersPurchased = false;
        await prefs.setBool('scenario_buynowpaylater_flowersPurchased', false);
      }
      if (!permanentlyPurchased.contains('202')) {
        _chocolatesPurchased = false;
        await prefs.setBool('scenario_buynowpaylater_chocolatesPurchased', false);
      }

      // Clear ephemeral states
      await _clearSavedState();
      // Also set the isTryAgain flag to false, so user cannot do it again:
      await prefs.setBool('scenario_buynowpaylater_isTryAgain', false);

      _tryAgainEnabled = false; // consumed the single "Try Again"
      _isTryAgain = false;
      _scenarioFirstTime = false; 
      _isReplay = true; // future attempts are replays
    }
    // If scenario is already done and we're in replay mode
    else {
      debugPrint("Scenario replay or subsequent attempt completion. Ephemeral revert, scenario remains completed in prefs.");
      // ephemeral revert
      int currentMainBalance = prefs.getInt('klooicash') ?? _originalBalance;
      if (currentMainBalance != _originalBalance) {
        await prefs.setInt('klooicash', _originalBalance);
      }
      _klooicash = _originalBalance;

      await prefs.remove('scenario_buynowpaylater_currentStep');
      await prefs.remove('scenario_buynowpaylater_showNextButton');
      await prefs.remove('scenario_buynowpaylater_showChoices');
      await prefs.remove('scenario_buynowpaylater_lastChoiceWasBNPL');
      await prefs.remove('scenario_buynowpaylater_userChoices');

      _accumulatedDeductions = 0;
      await prefs.setInt('scenario_buynowpaylater_accumulated_deductions', 0);

      // revert ephemeral purchases from replay
      List<String> permanentlyPurchased = prefs.getStringList('purchasedItems') ?? [];
      if (!permanentlyPurchased.contains('201')) {
        _flowersPurchased = false;
        await prefs.setBool('scenario_buynowpaylater_flowersPurchased', false);
      }
      if (!permanentlyPurchased.contains('202')) {
        _chocolatesPurchased = false;
        await prefs.setBool('scenario_buynowpaylater_chocolatesPurchased', false);
      }
    }
  }

  /// The single "Try Again" attempt.
  Future<void> _tryAgainScenario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Revert to original scenario balance
    _klooicash = _originalBalance;
    await prefs.setInt('klooicash', _originalBalance);

    // Clear ephemeral scenario states
    await _clearSavedState();

    // Persist that we are now in a single "try again" run
    await prefs.setBool('scenario_buynowpaylater_isTryAgain', true);

    setState(() {
      _currentScenarioIndex = 0;
      _showChoices = true;
      _scenarioCompleted = false;
      _chatMessages.clear();
      _userChoices.clear();
      _accumulatedDeductions = 0;

      // Mark that we are now in the single "try again" run
      _isTryAgain = true;
      _isReplay = false;
    });

    // Add the first message
    _addNPCMessage(
      _scenario.steps[_currentScenarioIndex].npcMessage,
      _scenario.steps[_currentScenarioIndex].npcName,
      animate: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
  }

  /// Replay after first-time + try again are done
  Future<void> _replayScenario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await _clearSavedState();

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
    });

    _addNPCMessage(
      _scenario.steps[_currentScenarioIndex].npcMessage,
      _scenario.steps[_currentScenarioIndex].npcName,
      animate: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
  }

  // ------------------------------------------------------
  //           FINAL FEEDBACK & MESSAGING
  // ------------------------------------------------------

  void _showEndScenarioFeedbackInChat() {
    _addDelimiter();
    String feedback = _analyzeUserChoices();
    String finalMessage;

    // If scenarioFirstTime and not in tryAgain => the first real completion
    if (_scenarioFirstTime && !_isTryAgain) {
      if (_klooicash > 0) {
        finalMessage = "You finished with some money left. Good job!\n\n"
            "You have a one-time Try Again option if you want a different path.\n\n"
            "$feedback";
      } else {
        finalMessage = "You ended up with no spare money. Some choices were costly.\n\n"
            "You have a one-time Try Again. Good luck!\n\n"
            "$feedback";
      }
    } 
    // If user is currently in the single tryAgain attempt
    else if (_isTryAgain) {
      if (_klooicash > 0) {
        finalMessage = "Try Again attempt ended with leftover money. Your main balance reverts.\n\n$feedback";
      } else {
        finalMessage = "Try Again attempt ended with no leftover money. Balance reverts.\n\n$feedback";
      }
    }
    // Replay
    else {
      if (_klooicash > 0) {
        finalMessage = "Replay ended with leftover money, but it reverts to original.\n\n$feedback";
      } else {
        finalMessage = "Replay ended with no leftover money, your balance reverts.\n\n$feedback";
      }
    }

    _addFinalFeedbackMessage(finalMessage);

    // Immediately save, so if user exits/resumes, they'll see final feedback
    _saveCurrentStep();
  }

  String _analyzeUserChoices() {
    if (_userChoices.isEmpty) {
      return "";
    }

    StringBuffer analysis = StringBuffer("Let’s look at your big choices:\n\n");

    // Just examples referencing indices of scenario choices:
    if (_userChoices.length > 1) {
      var concertChoice = _userChoices[1].text;
      if (concertChoice.contains("Pay 20K now")) {
        analysis.writeln("- Concert: Paid 20K upfront. No future debt.");
      } else if (concertChoice.contains("Use Klaro")) {
        analysis.writeln("- Concert: BNPL, short-term relief but future debt looming.");
      }
    }

    if (_userChoices.length > 3) {
      var phoneChoice = _userChoices[3].text;
      if (phoneChoice.contains("Pay 70K now")) {
        analysis.writeln("- Phone: Paid 70K now, no big debt later.");
      } else if (phoneChoice.contains("new phone via Klaro")) {
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
  }

  void _addUserMessage(String message) {
    _chatMessages.add({
      "type": "user",
      "speaker": _username,
      "message": message,
    });
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
  }

  void _addOutcomeMessage(String outcome, int kChange) {
    String feedback = "";
    // Show the (+/-) only if scenario is first attempt or in single tryAgain
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
  }

  void _addDelimiter() {
    _chatMessages.add({"type": "delimiter"});
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
  }

  void _addFinalFeedbackMessage(String feedback) {
    _chatMessages.add({"type": "outcome", "message": feedback});
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomWithAnimation());
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
  }

  bool _shouldShowShop() {
    // Show shop if user is at step 5 choosing grandma's gift
    return _currentScenarioIndex == 5 && !_scenarioCompleted && _showChoices;
  }

  Future<void> _openShop() async {
    // We’ll pass _isReplay so the shop knows ephemeral vs permanent purchase
    final purchasedNow = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        return RewardsShopScreen(
          isModal: true,
          isEphemeral: _isReplay,  // <--- Pass ephemeral flag
          initialCategoryId: 4,
          initialBalance: _klooicash,
          onClose: () {
            Navigator.pop(context, <int>{});
          },
          onKlooicashUpdate: (newBalance) {
            setState(() {
              _klooicash = newBalance.toInt();
            });
          },
        );
      },
    ) ?? <int>{};

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (purchasedNow.contains(201)) {
      _flowersPurchased = true;
      // If first or single tryAgain attempt => permanent. If replay => ephemeral only.
      if (!_isReplay) {
        List<String> permanent = prefs.getStringList('purchasedItems') ?? [];
        if (!permanent.contains('201')) {
          permanent.add('201');
          await prefs.setStringList('purchasedItems', permanent);
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
                  // If user is leaving from final scenario, ensure complete
                  await _completeScenario();
                } else if (_currentScenarioIndex > 0) {
                  // Save partial progress
                  await _saveCurrentStep();
                }
                Navigator.pop(context);
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
                      // If user is in the single try again run, final screen shows only Done
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
