class JournalEntry {
  final String id;
  final String title;
  final String note;
  final String createdAt;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.note,
    required this.createdAt,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'created_at': createdAt,
    };
  }
}
