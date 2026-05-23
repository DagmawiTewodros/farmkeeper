import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/calendar_local_datasource.dart';
import '../../data/calendar_repository.dart';
import '../../data/calendar_repository_impl.dart';
import '../../domain/calendar_event.dart';

final calendarLocalDataSourceProvider = Provider<CalendarLocalDataSource>((ref) {
  return CalendarLocalDataSource();
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl(ref.watch(calendarLocalDataSourceProvider));
});

final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  return ref.watch(calendarRepositoryProvider).getEvents();
});
