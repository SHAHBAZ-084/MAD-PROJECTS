import 'package:flutter/material.dart';

void main() {
  runApp(FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcard App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool showAnswer = false;

  final List<Map<String, String>> flashcards = [
    {"question": "What is the capital of France?", "answer": "Paris"},
    {"question": "What is 2 + 2?", "answer": "4"},
    {"question": "What is the national language of Pakistan?", "answer": "Urdu"},
    {"question": "Who developed Flutter?", "answer": "Google"},
    {"question": "What year was Dart released?", "answer": "2011"},
  ];

  void nextFlashcard() {
    setState(() {
      showAnswer = false;
      currentIndex = (currentIndex + 1) % flashcards.length;
    });
  }

  void flipCard() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flashcard App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: flipCard,
              child: Container(
                width: 300,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    showAnswer
                        ? flashcards[currentIndex]["answer"]!
                        : flashcards[currentIndex]["question"]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: nextFlashcard,
              icon: Icon(Icons.arrow_forward),
              label: Text("Next Flashcard"),
            ),
          ],
        ),
      ),
    );
  }
}
