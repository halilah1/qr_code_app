import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class QrScreen extends StatefulWidget {
  final String text;

  const QrScreen({
    super.key,
    required this.text,
  });

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _downloadQrCode() async {
    final boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) return;

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    final blob = web.Blob(
      [pngBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );

    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = 'qr_code.png';

    anchor.click();

    web.URL.revokeObjectURL(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: QrImageView(
                data: widget.text,
                size: 250,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.text),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _downloadQrCode,
              icon: const Icon(Icons.download),
              label: const Text('Download QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}