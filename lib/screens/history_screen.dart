import 'package:flutter/material.dart';

import '../models/qr_code.dart';
import '../services/api_service.dart';

import 'package:intl/intl.dart';

import 'qr_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<QrCode>> _codes;

  @override
  void initState() {
    super.initState();
    _codes = ApiService.getCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<QrCode>>(
        future: _codes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load QR code history'));
          }

          final codes = snapshot.data ?? [];

          if (codes.isEmpty) {
            return const Center(child: Text('No QR codes yet'));
          }

          return ListView.builder(
            itemCount: codes.length,
            itemBuilder: (context, index) {
              final code = codes[index];

              return ListTile(
                title: Text(code.text),
                subtitle: Text(
                  DateFormat('d MMM yyyy • h:mm a')
                      .format(code.createdAt.toLocal()),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrScreen(text: code.text),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
