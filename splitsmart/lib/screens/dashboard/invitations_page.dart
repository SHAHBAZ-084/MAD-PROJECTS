import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({Key? key}) : super(key: key);

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _invites = [];
  List<DocumentSnapshot> _inviteDocs = [];

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() { _loading = false; });
      return;
    }
    final invitesSnap = await FirebaseFirestore.instance
        .collection('groupInvites')
        .where('inviteeUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();
    final invites = invitesSnap.docs;
    if (invites.isEmpty) {
      setState(() { _invites = []; _inviteDocs = []; _loading = false; });
      return;
    }
    final inviterUids = invites.map((doc) => doc['inviterUid'] as String).toSet().toList();
    final groupIds = invites.map((doc) => doc['groupId'] as String).toSet().toList();
    final inviterSnaps = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: inviterUids)
        .get();
    final groupSnaps = await FirebaseFirestore.instance
        .collection('groups')
        .where(FieldPath.documentId, whereIn: groupIds)
        .get();
    final inviterMap = {for (var doc in inviterSnaps.docs) doc.id: doc.data()};
    final groupMap = {for (var doc in groupSnaps.docs) doc.id: doc.data()};
    setState(() {
      _invites = invites.map((invite) {
        final inviter = inviterMap[invite['inviterUid']] ?? {};
        final group = groupMap[invite['groupId']] ?? {};
        return {
          'inviterName': inviter['username'] ?? inviter['email'] ?? invite['inviterUid'],
          'inviterEmail': inviter['email'] ?? '',
          'groupName': group['name'] ?? invite['groupId'],
          'groupId': invite['groupId'],
          'inviteId': invite.id,
        };
      }).toList();
      _inviteDocs = invites;
      _loading = false;
    });
  }

  Future<void> _acceptInvite(int index) async {
    final invite = _invites[index];
    final inviteDoc = _inviteDocs[index];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    // Add user to group
    await FirebaseFirestore.instance.collection('groups').doc(invite['groupId']).update({
      'members': FieldValue.arrayUnion([uid]),
    });
    // Update invite status
    await inviteDoc.reference.update({'status': 'accepted'});
    setState(() {
      _invites.removeAt(index);
      _inviteDocs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation accepted.')));
  }

  Future<void> _rejectInvite(int index) async {
    final inviteDoc = _inviteDocs[index];
    await inviteDoc.reference.update({'status': 'rejected'});
    setState(() {
      _invites.removeAt(index);
      _inviteDocs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation rejected.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _invites.isEmpty
              ? const Center(child: Text('No invitations found.'))
              : ListView.separated(
                  itemCount: _invites.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final invite = _invites[index];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF001f3f)),
                      title: Text(invite['inviterName']),
                      subtitle: Text(invite['inviterEmail']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(invite['groupName']),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => _acceptInvite(index),
                                child: const Text('Accept'),
                              ),
                              TextButton(
                                onPressed: () => _rejectInvite(index),
                                child: const Text('Reject', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
} 