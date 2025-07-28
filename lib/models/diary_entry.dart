class DiaryEntry {
  final int? id;
  final String title;
  final String notes;
  final String? imagePath;
  final DateTime date;

  DiaryEntry({
    this.id,
    required this.title,
    required this.notes,
    this.imagePath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'imagePath': imagePath,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      notes: map['notes'] ?? '',
      imagePath: map['imagePath'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? title,
    String? notes,
    String? imagePath,
    DateTime? date,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
    );
  }
}
