import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Info',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey,
        //primarySwatch: Colors.brown,
      ),
      home: StudentInfoScreen(),
    );
  }
}

class StudentInfoScreen extends StatelessWidget {
  final String studentName = "Muhammad Shahbaz";
  final String registrationNumber = "FA22-BSE-084";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Student Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Student Name: $studentName",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Registration Number: $registrationNumber",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
