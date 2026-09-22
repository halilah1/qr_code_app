import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/qr_code.dart';
import '../services/api_service.dart';
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

  Future<void> _confirmDelete(QrCode code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete QR code?'),
          content: Text(
            'Are you sure you want to delete "${code.text}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteCode(code);
    }
  }

  Future<void> _deleteCode(QrCode code) async {
    try {
      await ApiService.deleteCode(code.id);

      if (!mounted) return;

      setState(() {
        _codes = ApiService.getCodes();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code deleted'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete QR code. Please try again.'),
        ),
      );
    }
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
            return const Center(
              child: Text('Failed to load QR code history'),
            );
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
                  DateFormat(
                    'd MMM yyyy • h:mm a',
                  ).format(code.createdAt.toLocal()),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete QR code',
                  onPressed: () {
                    _confirmDelete(code);
                  },
                ),
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