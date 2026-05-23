import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/journal_local_datasource.dart';
import '../../data/journal_repository.dart';
import '../../data/journal_repository_impl.dart';
import '../../domain/journal_entry.dart';

final journalLocalDataSourceProvider = Provider<JournalLocalDataSource>((ref) {
  return JournalLocalDataSource();
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(journalLocalDataSourceProvider));
});

final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  return ref.watch(journalRepositoryProvider).getEntries();
});
