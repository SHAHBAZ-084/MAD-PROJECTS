import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_expense_page.dart';
import 'add_member_page.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final bool isAdmin;

  const GroupDetailPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final TextEditingController _inviteController = TextEditingController();
  final TextEditingController _expenseTitleController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _expenseNotesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPayer;
  String? _inviteError;
  String? _expenseError;

  @override
  void dispose() {
    _inviteController.dispose();
    _expenseTitleController.dispose();
    _expenseAmountController.dispose();
    _expenseNotesController.dispose();
    super.dispose();
  }

  Future<void> _inviteMember(List<String> members) async {
    final usernameOrEmail = _inviteController.text.trim();
    if (usernameOrEmail.isEmpty) return;
    setState(() { _inviteError = null; });
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameOrEmail)
          .get();
      final emailSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: usernameOrEmail)
          .get();
      final userDoc = userSnap.docs.isNotEmpty
          ? userSnap.docs.first
          : (emailSnap.docs.isNotEmpty ? emailSnap.docs.first : null);
      if (userDoc == null) {
        setState(() { _inviteError = 'User not found'; });
        return;
      }
      final uid = userDoc.id;
      if (members.contains(uid)) {
        setState(() { _inviteError = 'User already in group'; });
        return;
      }
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'members': FieldValue.arrayUnion([uid]),
      });
      _inviteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User invited!')),
      );
    } catch (e) {
      setState(() { _inviteError = 'Failed to invite user'; });
    }
  }

  Future<void> _addExpense(List<String> members) async {
    final title = _expenseTitleController.text.trim();
    final amount = double.tryParse(_expenseAmountController.text.trim()) ?? 0;
    final notes = _expenseNotesController.text.trim();
    final paidBy = _selectedPayer;
    final date = _selectedDate ?? DateTime.now();
    setState(() { _expenseError = null; });
    if (title.isEmpty || amount <= 0 || paidBy == null) {
      setState(() { _expenseError = 'Fill all required fields'; });
      return;
    }
    final splitAmount = amount / members.length;
    final split = {for (var uid in members) uid: splitAmount};
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
      _expenseTitleController.clear();
      _expenseAmountController.clear();
      _expenseNotesController.clear();
      setState(() {
        _selectedDate = null;
        _selectedPayer = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added!')),
      );
    } catch (e) {
      setState(() { _expenseError = 'Failed to add expense'; });
    }
  }

  Future<Map<String, dynamic>> _fetchUsernames(List<String> uids) async {
    if (uids.isEmpty) return {};
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    return {
      for (var doc in snapshot.docs) doc.id: doc.data()['username'] ?? doc.id,
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots(),
      builder: (context, groupSnapshot) {
        if (!groupSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final groupData = groupSnapshot.data!.data() as Map<String, dynamic>?;
        if (groupData == null) {
          return const Center(child: Text('Group not found.'));
        }
        final members = List<String>.from(groupData['members'] ?? []);
        final admin = groupData['admin'] ?? '';
        final description = groupData['description'] ?? '';
        final initialAmount = groupData['initialAmount'] ?? 0;

        return FutureBuilder<Map<String, dynamic>>(
          future: _fetchUsernames(members),
          builder: (context, userSnap) {
            final usernames = userSnap.data ?? {};
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.groupName),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Color(0xFF001f3f)),
                    tooltip: 'Invite User',
                    onPressed: () async {
                      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
                      final groupData = groupDoc.data() as Map<String, dynamic>?;
                      if (groupData == null) return;
                      final members = List<String>.from(groupData['members'] ?? []);
                      // Fetch usernames for all members
                      final userSnaps = await FirebaseFirestore.instance
                          .collection('users')
                          .where(FieldPath.documentId, whereIn: members)
                          .get();
                      final usernames = {
                        for (var doc in userSnaps.docs) doc.id: doc.data()['username'] ?? doc.id,
                      };
                      if (!mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMemberPage(
                            groupId: widget.groupId,
                            currentMembers: members,
                            usernames: Map<String, String>.from(usernames),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard summary at the top
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('expenses')
                          .where('groupId', isEqualTo: widget.groupId)
                          .snapshots(),
                      builder: (context, expenseSnap) {
                        if (!expenseSnap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final expenses = expenseSnap.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return {
                            'title': data['title'] ?? '',
                            'amount': (data['amount'] ?? 0).toDouble(),
                            'paidBy': data['paidBy'] ?? '',
                            'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                            'notes': data['notes'] ?? '',
                            'split': Map<String, double>.from(data['split'] ?? {}),
                          };
                        }).toList();
                        final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + (e['amount'] as double));
                        final individualShare = members.isNotEmpty ? totalExpenses / members.length : 0.0;
                        // Calculate balances
                        final Map<String, double> balances = {for (var m in members) m: 0.0};
                        for (final expense in expenses) {
                          final split = expense['split'] as Map<String, double>;
                          balances[expense['paidBy']] = (balances[expense['paidBy']] ?? 0) + (expense['amount'] as double);
                          for (final entry in split.entries) {
                            balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3D5A80), Color(0xFF98C1D9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.dashboard, color: Colors.white, size: 28),
                                        const SizedBox(width: 10),
                                        const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.white,
                                          child: (usernames[admin] ?? admin).isNotEmpty
                                              ? Text((usernames[admin] ?? admin).substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
                                              : const Icon(Icons.person, color: Colors.amber),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 20),
                                        const SizedBox(width: 6),
                                        Text('Admin: ', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                                        Text(
                                          usernames[admin] ?? admin,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    if (description.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.description, color: Colors.white70, size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              description,
                                              style: const TextStyle(fontSize: 13, color: Colors.white70, fontStyle: FontStyle.italic),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.attach_money, color: Colors.amber, size: 22),
                                        const SizedBox(width: 8),
                                        Text('Initial: ', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                                        Text('₹$initialAmount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.savings, color: Colors.greenAccent, size: 22),
                                        const SizedBox(width: 8),
                                        Text('Total: ', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                                        Text('₹${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.group, color: Colors.purpleAccent, size: 22),
                                        const SizedBox(width: 8),
                                        Text('Share: ', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                                        Text('₹${individualShare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(color: Colors.white24, thickness: 1),
                                    const SizedBox(height: 8),
                                    Text('Balances:', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    ...balances.entries.map((e) {
                                      final value = e.value;
                                      final color = value > 0 ? Colors.green : value < 0 ? Colors.red : Colors.grey;
                                      final isAdmin = e.key == admin;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 3),
                                        decoration: isAdmin
                                            ? BoxDecoration(
                                                color: Colors.amber.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.amber, width: 1.2),
                                              )
                                            : null,
                                        child: Row(
                                          children: [
                                            Icon(value > 0 ? Icons.arrow_upward : value < 0 ? Icons.arrow_downward : Icons.remove, color: color, size: 18),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${usernames[e.key] ?? e.key}${isAdmin ? ' (admin)' : ''}: ',
                                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                            ),
                                            if (isAdmin)
                                              const Icon(Icons.star, color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Chip(
                                              label: Text('₹${value.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                                              backgroundColor: color,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.teal),
                      title: const Text('Description'),
                      subtitle: Text(
                        description.isNotEmpty ? description : 'No description',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Members:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...members.where((m) => m != admin).map((m) {
                      final isCurrentAdmin = admin == m;
                      final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == m;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: (usernames[m] ?? m).isNotEmpty
                              ? Text((usernames[m] ?? m).substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                              : const Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(usernames[m] ?? m),
                        subtitle: isCurrentAdmin ? const Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)) : null,
                        trailing: widget.isAdmin && !isCurrentAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                                    tooltip: 'Make Admin',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Transfer Admin'),
                                          content: Text('Make ${usernames[m] ?? m} the new admin?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({'admin': m});
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin transferred.')));
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    tooltip: 'Remove Member',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Remove Member'),
                                          content: Text('Remove ${usernames[m] ?? m} from the group?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
                                          'members': FieldValue.arrayRemove([m]),
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member removed.')));
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              )
                            : null,
                      );
                    }).toList(),
                    const Divider(height: 32),
                    const Text('Expense History:'),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('expenses')
                          .where('groupId', isEqualTo: widget.groupId)
                          .snapshots(),
                      builder: (context, expenseSnap) {
                        if (!expenseSnap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final expenses = expenseSnap.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return {
                            'title': data['title'] ?? '',
                            'amount': (data['amount'] ?? 0).toDouble(),
                            'paidBy': data['paidBy'] ?? '',
                            'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                            'notes': data['notes'] ?? '',
                            'split': Map<String, double>.from(data['split'] ?? {}),
                          };
                        }).toList();
                        if (expenses.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('No expenses yet.'),
                          );
                        }
                        return Column(
                          children: expenses.map((e) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: (usernames[e['paidBy']] ?? e['paidBy']).isNotEmpty
                                    ? Text((usernames[e['paidBy']] ?? e['paidBy']).substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                    : const Icon(Icons.person, color: Colors.green),
                              ),
                              title: Text(e['title']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Paid by: ${(usernames[e['paidBy']] ?? e['paidBy'])}'),
                                  Text('Amount: ₹${(e['amount'] as double).toStringAsFixed(2)}'),
                                  if ((e['notes'] as String).isNotEmpty) Text('Notes: ${e['notes']}'),
                                ],
                              ),
                              trailing: Text('${(e['date'] as DateTime).toLocal()}'.split(' ')[0]),
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpensePage(
                        groupId: widget.groupId,
                        members: members,
                        usernames: Map<String, String>.from(usernames),
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
                child: const Icon(Icons.add),
                tooltip: 'Add Expense',
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }
} 