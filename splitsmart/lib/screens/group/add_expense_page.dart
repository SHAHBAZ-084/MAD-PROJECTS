import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpensePage extends StatefulWidget {
  final String groupId;
  final List<String> members;
  final Map<String, String> usernames;

  const AddExpensePage({
    Key? key,
    required this.groupId,
    required this.members,
    required this.usernames,
  }) : super(key: key);

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _paidBy;
  DateTime _date = DateTime.now();
  String? _error;
  bool _loading = false;
  bool _customSplit = false;
  Map<String, TextEditingController> _customControllers = {};

  @override
  void initState() {
    super.initState();
    for (var uid in widget.members) {
      _customControllers[uid] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    for (var c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addExpense() async {
    setState(() { _error = null; _loading = true; });
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final notes = _notesController.text.trim();
    final paidBy = _paidBy;
    final date = _date;
    if (title.isEmpty || amount <= 0 || paidBy == null) {
      setState(() { _error = 'Fill all required fields'; _loading = false; });
      return;
    }
    Map<String, double> split;
    if (_customSplit) {
      split = {};
      double sum = 0;
      for (var uid in widget.members) {
        final val = double.tryParse(_customControllers[uid]?.text.trim() ?? '');
        if (val == null || val < 0) {
          setState(() { _error = 'Enter valid custom shares for all members'; _loading = false; });
          return;
        }
        split[uid] = val;
        sum += val;
      }
      if ((sum - amount).abs() > 0.01) {
        setState(() { _error = 'Custom shares must sum to total amount'; _loading = false; });
        return;
      }
    } else {
      final splitAmount = amount / widget.members.length;
      split = {for (var uid in widget.members) uid: splitAmount};
    }
    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'groupId': widget.groupId,
        'title': title,
        'amount': amount,
        'paidBy': paidBy,
        'date': date,
        'notes': notes,
        'split': split,
      });
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added!')),
        );
      }
    } catch (e) {
      setState(() { _error = 'Failed to add expense'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paidBy,
                items: widget.members.map((uid) => DropdownMenuItem(
                  value: uid,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue.shade100,
                        child: (widget.usernames[uid] ?? uid).isNotEmpty
                            ? Text((widget.usernames[uid] ?? uid).substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14))
                            : const Icon(Icons.person, color: Colors.blue, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.usernames[uid] ?? uid),
                    ],
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _paidBy = v),
                decoration: const InputDecoration(
                  labelText: 'Paid by',
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Date: ${_date.toLocal()}'.split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Split:'),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Equal'),
                    selected: !_customSplit,
                    onSelected: (v) => setState(() => _customSplit = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _customSplit,
                    onSelected: (v) => setState(() => _customSplit = true),
                  ),
                ],
              ),
              if (_customSplit) ...[
                const SizedBox(height: 12),
                ...widget.members.map((uid) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _customControllers[uid],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Share for ${widget.usernames[uid] ?? uid}',
                    ),
                  ),
                )),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note_alt),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _addExpense,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 