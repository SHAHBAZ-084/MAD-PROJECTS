import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(CommitteeApp());
}

class CommitteeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Committee Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CommitteeSetupScreen(),
    );
  }
}

// Screen to set the fixed deposit amount
class CommitteeSetupScreen extends StatefulWidget {
  @override
  _CommitteeSetupScreenState createState() => _CommitteeSetupScreenState();
}

class _CommitteeSetupScreenState extends State<CommitteeSetupScreen> {
  final TextEditingController depositAmountController = TextEditingController();
  double? depositAmount;

  void startCommittee() {
    double? amount = double.tryParse(depositAmountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("⚠ Please enter a valid deposit amount!")));
      return;
    }

    setState(() {
      depositAmount = amount;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommitteeScreen(fixedDepositAmount: depositAmount!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Up Committee")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter Fixed Deposit Amount for All Members",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: depositAmountController,
              decoration: InputDecoration(labelText: "Deposit Amount"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: startCommittee,
                icon: Icon(Icons.start),
                label: Text("Start Committee")),
          ],
        ),
      ),
    );
  }
}

// Committee Management Screen
class CommitteeScreen extends StatefulWidget {
  final double fixedDepositAmount;

  CommitteeScreen({required this.fixedDepositAmount});

  @override
  _CommitteeScreenState createState() => _CommitteeScreenState();
}

class _CommitteeScreenState extends State<CommitteeScreen> {
  final List<String> members = [];
  List<String> paymentOrder = [];
  Set<String> paidMembers = {};
  int currentMonthIndex = 0;

  final TextEditingController nameController = TextEditingController();

  void addMember() {
    String name = nameController.text.trim();

    if (name.isEmpty) {
      _showMessage("❌ Please enter a valid name!");
      return;
    }

    if (members.contains(name)) {
      _showMessage("⚠ '$name' is already in the committee!");
      return;
    }

    setState(() {
      members.add(name);
    });

    nameController.clear();
    _showMessage("✅ '$name' joined the Committee!");
  }

  void generatePaymentOrder() {
    if (members.length < 2) {
      _showMessage("⚠ At least 2 members are required!");
      return;
    }

    setState(() {
      paymentOrder = List.from(members)..shuffle(Random());
      paidMembers.clear();
      currentMonthIndex = 0;
    });

    _showDialog("Payment Order Generated",
        "Payment will be given to: ${paymentOrder.join(", ")}");
  }

  void distributeAmount() {
    if (paymentOrder.isEmpty) {
      _showMessage("⚠ Generate Payment Order First!");
      return;
    }

    while (currentMonthIndex < paymentOrder.length &&
        paidMembers.contains(paymentOrder[currentMonthIndex])) {
      currentMonthIndex++;
    }

    if (currentMonthIndex >= paymentOrder.length) {
      _showMessage("✅ Committee Cycle Completed! Restarting new cycle.");
      generatePaymentOrder();
      return;
    }

    String receiver = paymentOrder[currentMonthIndex];
    paidMembers.add(receiver);

    _showDialog("Payment for This Month", "💰 $receiver receives the amount!");
    setState(() {
      currentMonthIndex++;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Committee Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Fixed Deposit Amount: \$${widget.fixedDepositAmount}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Enter Member Name"),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
                onPressed: addMember,
                icon: Icon(Icons.person_add),
                label: Text("Add Member")),

            Divider(),

            Text("Members List:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${members[index]}"),
                    subtitle: Text("Deposit: \$${widget.fixedDepositAmount}"),
                    trailing: paidMembers.contains(members[index])
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.pending, color: Colors.red),
                  );
                },
              ),
            ),

            SizedBox(height: 10),
            ElevatedButton.icon(
                onPressed: generatePaymentOrder,
                icon: Icon(Icons.shuffle),
                label: Text("Generate Payment Order")),

            SizedBox(height: 10),
            ElevatedButton.icon(
                onPressed: distributeAmount,
                icon: Icon(Icons.attach_money),
                label: Text("Distribute Amount")),
          ],
        ),
      ),
    );
  }
}
