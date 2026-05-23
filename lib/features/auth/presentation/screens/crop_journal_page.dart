import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../journal/domain/journal_entry.dart';
import '../../../journal/presentation/providers/journal_provider.dart';

class CropJournalPage extends ConsumerWidget {
  const CropJournalPage({super.key});

  static const Color bgColor = Color(0xffF9FAF5);
  static const Color darkGreen = Color(0xff2A6F2B);
  static const Color textGrey = Color(0xff7A8677);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesState = ref.watch(journalEntriesProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Journal',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications_screen'),
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: darkGreen,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FIELD NOTES',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              'Crop Journal',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Notes saved on this device.',
              style: TextStyle(color: textGrey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addEntry(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('New Entry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(journalEntriesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entriesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
                data: (entries) {
                  if (entries.isEmpty)
                    return const Center(child: Text('No journal entries yet.'));
                  return ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.menu_book,
                            color: darkGreen,
                          ),
                          title: Text(entry.title),
                          subtitle: Text('${entry.createdAt}\n${entry.note}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteEntry(context, ref, entry.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEntry(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    await ref
        .read(journalRepositoryProvider)
        .saveEntry(
          JournalEntry(
            id: now.microsecondsSinceEpoch.toString(),
            title: 'Field Note',
            note: 'Created locally from the journal screen.',
            createdAt: now.toIso8601String(),
          ),
        );
    ref.invalidate(journalEntriesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Journal entry saved.')));
    }
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    await ref.read(journalRepositoryProvider).deleteEntry(id);
    ref.invalidate(journalEntriesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Journal entry deleted.')));
    }
  }
}
