class QrCode {
  final int id;
  final String text;
  final DateTime createdAt;

  const QrCode({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      id: json['id'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}