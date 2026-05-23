import '../domain/journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getEntries();
  Future<void> saveEntry(JournalEntry entry);
  Future<void> deleteEntry(String id);
}
