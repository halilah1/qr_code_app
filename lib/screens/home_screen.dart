import 'package:flutter/material.dart';

import '../services/api_service.dart';

import 'qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();

  String? _validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter some text or a URL';
    }

    return null;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Generator')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                validator: _validateText,
                decoration: const InputDecoration(
                  labelText: 'Enter text or URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final text = _textController.text.trim();

                    await ApiService.createCode(text);

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrScreen(text: text),
                      ),
                    );
                  }
                },
                child: const Text('Generate QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
