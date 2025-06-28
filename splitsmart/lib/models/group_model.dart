import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String admin;
  final List<String> members;
  final String? description;
  final double initialAmount;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.admin,
    required this.members,
    this.description,
    required this.initialAmount,
    required this.createdAt,
  });

  factory GroupModel.fromMap(String id, Map<String, dynamic> data) {
    return GroupModel(
      id: id,
      name: data['name'] ?? '',
      admin: data['admin'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      description: data['description'],
      initialAmount: (data['initialAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'admin': admin,
      'members': members,
      'description': description,
      'initialAmount': initialAmount,
      'createdAt': createdAt,
    };
  }
}

extension GroupCalculations on GroupModel {
  /// Returns a map of userId -> balance (positive: gets, negative: owes)
  Map<String, double> calculateBalances(List<ExpenseModel> expenses) {
    final Map<String, double> balances = {for (var m in members) m: 0.0};
    for (final expense in expenses) {
      if (expense.groupId != id) continue;
      final split = expense.split;
      // The payer gets the full amount, others owe their share
      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;
      for (final entry in split.entries) {
        balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
      }
    }
    return balances;
  }
} 