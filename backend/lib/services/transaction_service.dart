// lib/services/transaction_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionRecord {
  final String description;
  final int amount;
  final String date;

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

  static String getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  bool get isBNPL => description.toLowerCase().contains("(klaro)");
  bool get isPending => date.toLowerCase() == "pending";
}

class TransactionService {
  static const String userTransactionsKey = 'user_transactions';

  static Future<List<TransactionRecord>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(userTransactionsKey) ?? [];
    return rawList.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return TransactionRecord.fromJson(map);
    }).toList();
  }

  static Future<void> saveTransactions(List<TransactionRecord> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final newRawList = transactions.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList(userTransactionsKey, newRawList);
  }

  static Future<void> prependTransactions(List<TransactionRecord> newTx) async {
    final existing = await loadTransactions();
    existing.insertAll(0, newTx);
    await saveTransactions(existing);
  }

  static Future<bool> updateTransaction(TransactionRecord oldTx, TransactionRecord newTx) async {
    final existing = await loadTransactions();
    final index = existing.indexWhere((tx) =>
        tx.description == oldTx.description && tx.amount == oldTx.amount && tx.date == oldTx.date);
    if (index != -1) {
      existing[index] = newTx;
      await saveTransactions(existing);
      return true;
    }
    return false;
  }

  static Future<List<TransactionRecord>> getPendingKlaroTransactions() async {
    final all = await loadTransactions();
    return all.where((tx) => tx.isBNPL && tx.isPending).toList();
  }

  // Helper method to mark a Klaro transaction as paid:
  static Future<bool> payKlaroTransaction(String description) async {
    // Pay off the first pending Klaro transaction matching this description.
    final all = await loadTransactions();
    final index = all.indexWhere((tx) => tx.isBNPL && tx.description == description && tx.isPending);
    if (index == -1) return false; // no matching pending transaction
    final oldTx = all[index];
    final newTx = TransactionRecord(
      description: oldTx.description,
      amount: oldTx.amount,
      date: TransactionRecord.getTodayDateString(),
    );
    all[index] = newTx;
    await saveTransactions(all);
    return true;
  }

  // Add a transaction for interest charges
  static Future<void> addInterestTransaction(String description, int interestAmount) async {
    final interestTx = TransactionRecord(
      description: "$description Interest",
      amount: -interestAmount,
      date: TransactionRecord.getTodayDateString(),
    );
    await prependTransactions([interestTx]);
  }

  // NEW: Add a Klooicash transaction
  static Future<void> addKlooicash(int amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentKlooicash = prefs.getInt('klooicash') ?? 500;
    int newKlooicash = currentKlooicash + amount;
    await prefs.setInt('klooicash', newKlooicash);

    // Add a transaction record
    TransactionRecord tx = TransactionRecord(
      description: 'Daily Task Reward',
      amount: amount,
      date: TransactionRecord.getTodayDateString(),
    );
    await prependTransactions([tx]);
  }
}
