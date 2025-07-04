import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../landing/landing_page.dart';
import '../profile/profile_page.dart';
import '../../models/group_model.dart';
import '../../models/expense_model.dart';
import '../group/group_detail_page.dart';
import 'invitations_page.dart';

class DashboardPage extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  final bool darkMode;
  const DashboardPage({super.key, this.onThemeChanged, this.darkMode = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _showAddGroupDialog() async {
    final TextEditingController _groupNameController = TextEditingController();
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _descController = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Group'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _groupNameController,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        errorText: error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Initial Amount (optional)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Group Description (optional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = _groupNameController.text.trim();
                    final amountText = _amountController.text.trim();
                    final desc = _descController.text.trim();
                    if (name.isEmpty) {
                      setState(() => error = 'Group name required');
                      return;
                    }
                    double? amount = double.tryParse(amountText);
                    final group = GroupModel(
                      id: '',
                      name: name,
                      admin: user!.uid,
                      members: [user!.uid],
                      description: desc.isEmpty ? null : desc,
                      initialAmount: amount ?? 0.0,
                      createdAt: DateTime.now(),
                    );
                    await FirebaseFirestore.instance.collection('groups').add(group.toMap());
                    Navigator.of(context).pop();
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<ExpenseModel>> _fetchGroupExpenses(String groupId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .get();
    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, String>> _fetchUsernames(List<String> uids) async {
    if (uids.isEmpty) return {};
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    return {
      for (var doc in snapshot.docs) doc.id: doc.data()['username'] ?? doc.id,
    };
  }

  Future<void> _inviteMemberDialog(GroupModel group) async {
    final TextEditingController _inviteController = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Invite Member'),
              content: TextField(
                controller: _inviteController,
                decoration: InputDecoration(
                  labelText: 'Username or Email',
                  errorText: error,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final input = _inviteController.text.trim();
                    if (input.isEmpty) {
                      setState(() => error = 'Enter username or email');
                      return;
                    }
                    final userSnap = await FirebaseFirestore.instance
                        .collection('users')
                        .where('username', isEqualTo: input)
                        .get();
                    final emailSnap = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: input)
                        .get();
                    final userDoc = userSnap.docs.isNotEmpty
                        ? userSnap.docs.first
                        : (emailSnap.docs.isNotEmpty ? emailSnap.docs.first : null);
                    if (userDoc == null) {
                      setState(() => error = 'User not found');
                      return;
                    }
                    final uid = userDoc.id;
                    if (group.members.contains(uid)) {
                      setState(() => error = 'User already in group');
                      return;
                    }
                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(group.id)
                        .update({
                      'members': FieldValue.arrayUnion([uid]),
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User invited!')),
                    );
                  },
                  child: const Text('Invite'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addExpenseDialog(GroupModel group, Map<String, String> usernames) async {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _notesController = TextEditingController();
    String? paidBy = group.members.first;
    DateTime date = DateTime.now();
    String? error;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: paidBy,
                      items: group.members
                          .map((uid) => DropdownMenuItem(
                                value: uid,
                                child: Text(usernames[uid] ?? uid),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => paidBy = val),
                      decoration: const InputDecoration(labelText: 'Paid By'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Date:'),
                        const SizedBox(width: 8),
                        Text('${date.toLocal()}'.split(' ')[0]),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => date = picked);
                          },
                        ),
                      ],
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(error!, style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    final amountText = _amountController.text.trim();
                    final notes = _notesController.text.trim();
                    if (title.isEmpty || amountText.isEmpty || paidBy == null) {
                      setState(() => error = 'Fill all required fields');
                      return;
                    }
                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) {
                      setState(() => error = 'Enter a valid amount');
                      return;
                    }
                    // Split equally
                    final splitAmount = amount / group.members.length;
                    final split = {for (var uid in group.members) uid: splitAmount};
                    final expense = ExpenseModel(
                      id: '',
                      groupId: group.id,
                      title: title,
                      amount: amount,
                      paidBy: paidBy!,
                      date: date,
                      notes: notes,
                      split: split,
                    );
                    await FirebaseFirestore.instance.collection('expenses').add(expense.toMap());
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense added!')),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showGroupDetailsDialog(GroupModel group) async {
    final expenses = await _fetchGroupExpenses(group.id);
    final balances = group.calculateBalances(expenses);
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final individualShare = group.members.isNotEmpty ? totalExpenses / group.members.length : 0.0;
    final usernames = await _fetchUsernames(group.members);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(group.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin: ${usernames[group.admin] ?? group.admin}'),
                const SizedBox(height: 8),
                Text('Members: ${group.members.length}'),
                ...group.members.map((uid) => Text('• ${usernames[uid] ?? uid}')),
                const SizedBox(height: 8),
                if (group.description != null && group.description!.isNotEmpty)
                  Text('Description: ${group.description}'),
                const SizedBox(height: 8),
                Text('Initial Amount: ${group.initialAmount}'),
                const Divider(),
                Text('Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}'),
                Text('Individual Share: ₹${individualShare.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Balances:'),
                ...balances.entries.map((e) => Text('• ${(usernames[e.key] ?? e.key)}: ₹${e.value.toStringAsFixed(2)}')),
                const SizedBox(height: 8),
                Text('Expense History:'),
                ...expenses.map((e) => ListTile(
                      title: Text(e.title),
                      subtitle: Text('Paid by: ${e.paidBy}, Amount: ₹${e.amount.toStringAsFixed(2)}'),
                      trailing: Text('${e.date.toLocal()}'.split(' ')[0]),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitSmart'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Color(0xFF001f3f)),
            tooltip: 'Invitations',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InvitationsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    onThemeChanged: widget.onThemeChanged,
                    darkMode: widget.darkMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF001f3f), Color(0xFFFFFFFF)],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .where('members', arrayContains: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No groups found. Tap + to add one!'));
              }
              final groups = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = GroupModel.fromMap(
                    groups[index].id,
                    groups[index].data() as Map<String, dynamic>,
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFF6F8FB),
                    child: ListTile(
                      leading: const Icon(Icons.group, color: Color(0xFF001f3f)),
                      title: Text(group.name),
                      subtitle: Text('Members: ${group.members.length}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailPage(
                              groupId: group.id,
                              groupName: group.name,
                              isAdmin: group.admin == user?.uid,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: const Icon(Icons.group_add, color: Colors.white),
        backgroundColor: const Color(0xFF001f3f),
        tooltip: 'Add Group',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
} 