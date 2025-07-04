import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMemberPage extends StatefulWidget {
  final String groupId;
  final List<String> currentMembers;
  final Map<String, String> usernames;

  const AddMemberPage({
    Key? key,
    required this.groupId,
    required this.currentMembers,
    required this.usernames,
  }) : super(key: key);

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    setState(() { _loading = true; _error = null; });
    query = query.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() { _searchResults = []; _loading = false; });
      return;
    }
    try {
      // Search by username prefix
      final usernameSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .limit(10)
          .get();
      // Search by email prefix
      final emailSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + 'z')
          .limit(10)
          .get();
      final seen = <String>{};
      final results = <Map<String, dynamic>>[];
      for (var doc in usernameSnap.docs) {
        if (!widget.currentMembers.contains(doc.id) && !seen.contains(doc.id)) {
          results.add({'uid': doc.id, ...doc.data()});
          seen.add(doc.id);
        }
      }
      for (var doc in emailSnap.docs) {
        if (!widget.currentMembers.contains(doc.id) && !seen.contains(doc.id)) {
          results.add({'uid': doc.id, ...doc.data()});
          seen.add(doc.id);
        }
      }
      setState(() { _searchResults = results; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Search failed'; _loading = false; });
    }
  }

  Future<void> _inviteUser(String uid) async {
    try {
      final inviterUid = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get();
      await FirebaseFirestore.instance.collection('groupInvites').add({
        'groupId': widget.groupId,
        'inviteeUid': uid,
        'inviterUid': FirebaseAuth.instance.currentUser?.uid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent!')));
      setState(() {
        _searchResults.removeWhere((u) => u['uid'] == uid);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send invitation.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Members:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: widget.currentMembers.map((uid) => Chip(
                label: Text(widget.usernames[uid] ?? uid),
                avatar: CircleAvatar(
                  child: Text((widget.usernames[uid] ?? uid).substring(0, 1).toUpperCase()),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by username or email',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchUsers,
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text((user['username'] ?? user['email'] ?? '').isNotEmpty
                            ? (user['username'] ?? user['email'])[0].toUpperCase()
                            : '?'),
                      ),
                      title: Text(user['username'] ?? user['email'] ?? user['uid']),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Invite'),
                        onPressed: () => _inviteUser(user['uid']),
                      ),
                    );
                  },
                ),
              ),
            if (!_loading && _searchResults.isEmpty && _searchController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text('No users found.'),
              ),
          ],
        ),
      ),
    );
  }
} 