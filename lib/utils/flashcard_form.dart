import 'package:flashcard_app/models/database_helper.dart';
import 'package:flutter/material.dart';

class FlashcardFormScreen extends StatefulWidget {
  final Map<String, dynamic>? flashcard;

  FlashcardFormScreen({this.flashcard});

  @override
  _FlashcardFormScreenState createState() => _FlashcardFormScreenState();
}

class _FlashcardFormScreenState extends State<FlashcardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.flashcard != null) {
      _questionController.text = widget.flashcard!['question'];
      _answerController.text = widget.flashcard!['answer'];
    }
  }

  Future<void> _saveFlashcard() async {
    if (_formKey.currentState!.validate()) {
      final question = _questionController.text.trim();
      final answer = _answerController.text.trim();

      // Check for duplicate questions
      final isDuplicate = await _dbHelper.doesQuestionExist(question);

      if (isDuplicate && widget.flashcard == null) {
        _showAlert('Duplicate Question', 'This question already exists.');
        return;
      }

      final data = {'question': question, 'answer': answer};

      if (widget.flashcard == null) {
        // Insert new flashcard
        await _dbHelper.insertFlashcard(data);
      } else {
        // Update existing flashcard
        await _dbHelper.updateFlashcard(widget.flashcard!['id'], data);
      }
      Navigator.pop(context, true);
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flashcard == null ? 'Add Flashcard' : 'Edit Flashcard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
                validator: (value) =>
                    value!.isEmpty ? 'Question cannot be empty' : null,
              ),
              TextFormField(
                controller: _answerController,
                decoration: InputDecoration(labelText: 'Answer'),
                validator: (value) =>
                    value!.isEmpty ? 'Answer cannot be empty' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveFlashcard,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
