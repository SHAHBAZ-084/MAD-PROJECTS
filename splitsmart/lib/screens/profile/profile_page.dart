import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../landing/landing_page.dart';

class ProfilePage extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  final bool darkMode;
  const ProfilePage({super.key, this.onThemeChanged, this.darkMode = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenForInvites();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      _usernameController.text = userDoc.data()?['username'] ?? '';
      _fullNameController.text = userDoc.data()?['fullName'] ?? '';
    }
  }

  void _listenForInvites() {
    if (user == null) return;
    FirebaseFirestore.instance
        .collection('groupInvites')
        .where('inviteeUid', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) async {
      for (final docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          if (data == null) continue;
          final inviterUid = data['inviterUid'];
          final groupId = data['groupId'];
          // Fetch inviter info
          final inviterDoc = await FirebaseFirestore.instance.collection('users').doc(inviterUid).get();
          final inviterName = inviterDoc.data()?['username'] ?? inviterUid;
          final inviterEmail = inviterDoc.data()?['email'] ?? '';
          // Fetch group info
          final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
          final groupName = groupDoc.data()?['name'] ?? groupId;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You have been invited by $inviterName ($inviterEmail) to join the group "$groupName".',
                ),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _updateProfile() async {
    setState(() { _loading = true; _error = null; });
    final newUsername = _usernameController.text.trim();
    final newFullName = _fullNameController.text.trim();
    if (newUsername.isEmpty || newFullName.isEmpty) {
      setState(() { _error = 'Fields cannot be empty'; _loading = false; });
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'username': newUsername,
        'fullName': newFullName,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      setState(() { _error = 'Failed to update profile'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      await user!.delete();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully!')),
        );
      }
    } catch (e) {
      setState(() { _error = 'Failed to delete account!'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Icon(Icons.account_circle, size: 80, color: Color(0xFF001f3f)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
                const SizedBox(height: 18),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text('Update Profile'),
                        ),
                      ),
                const Divider(height: 40),
                SwitchListTile(
                  value: widget.darkMode,
                  onChanged: (val) {
                    if (widget.onThemeChanged != null) {
                      widget.onThemeChanged!(val);
                    }
                  },
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.brightness_6),
                ),
                const Divider(height: 40),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: null,
                  onTap: () {},
                ),
                // Notifications list
                StreamBuilder<QuerySnapshot>(
                  stream: user != null
                      ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('notifications')
                          .orderBy('timestamp', descending: true)
                          .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No notifications.'),
                      );
                    }
                    final notifications = snapshot.data!.docs;
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final data = notifications[index].data() as Map<String, dynamic>;
                        final message = data['message'] ?? '';
                        final ts = data['timestamp'] as Timestamp?;
                        final date = ts != null ? ts.toDate() : null;
                        return ListTile(
                          leading: const Icon(Icons.notifications_active, color: Color(0xFF001f3f)),
                          title: Text(message),
                          subtitle: date != null ? Text('${date.toLocal()}') : null,
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Color(0xFF001f3f)),
                    label: const Text('Logout', style: TextStyle(color: Color(0xFF001f3f))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF001f3f)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 