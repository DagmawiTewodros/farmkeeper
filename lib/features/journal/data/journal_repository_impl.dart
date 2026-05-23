import '../domain/journal_entry.dart';
import 'journal_local_datasource.dart';
import 'journal_repository.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource localDataSource;

  const JournalRepositoryImpl(this.localDataSource);

  @override
  Future<List<JournalEntry>> getEntries() async {
    final cached = await localDataSource.getEntries();
    if (cached.isNotEmpty) return cached;
    return [];
  }

  @override
  Future<void> saveEntry(JournalEntry entry) {
    return localDataSource.saveEntry(entry);
  }

  @override
  Future<void> deleteEntry(String id) {
    return localDataSource.deleteEntry(id);
  }
}
