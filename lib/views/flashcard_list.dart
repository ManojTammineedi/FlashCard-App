import 'package:flashcard_app/utils/flashcard_form.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../models/database_helper.dart';

class FlashcardListScreen extends StatefulWidget {
  @override
  _FlashcardListScreenState createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _flashcards = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final data = await _dbHelper.fetchFlashcards();
    setState(() {
      _flashcards = data;
      _currentIndex = 0; // Reset to the first flashcard
    });
  }

  Future<void> _deleteFlashcard(int id) async {
    await _dbHelper.deleteFlashcard(id);
    _loadFlashcards();
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Flashcard'),
        content: Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteFlashcard(id);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFlashcardForm({Map<String, dynamic>? flashcard}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardFormScreen(flashcard: flashcard),
      ),
    );
    if (result == true) _loadFlashcards();
  }

  void _goToPrevious() {
    setState(() {
      if (_currentIndex > 0) _currentIndex--;
    });
  }

  void _goToNext() {
    setState(() {
      if (_currentIndex < _flashcards.length - 1) _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Text(
                    'FlashCards',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          )),
      body: Center(
        child: _flashcards.isEmpty
            ? Text('No Flashcards Available', style: TextStyle(fontSize: 18))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    margin: EdgeInsets.all(36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlipCard(
                            front: Container(
                              width: 300,
                              height: 200,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _flashcards[_currentIndex]['question'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            back: Container(
                              width: 300,
                              height: 200,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  _flashcards[_currentIndex]['answer'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Tap on the question to see the answer",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showFlashcardForm(
                                    flashcard: _flashcards[_currentIndex]),
                              ),
                              SizedBox(width: 20),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmation(
                                    _flashcards[_currentIndex]['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _currentIndex > 0 ? _goToPrevious : null,
                        child: Icon(Icons.arrow_back_outlined),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _currentIndex < _flashcards.length - 1
                            ? _goToNext
                            : null,
                        child: Icon(Icons.arrow_forward_outlined),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showFlashcardForm(),
      ),
    );
  }
}
