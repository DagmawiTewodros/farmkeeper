import '../domain/calendar_event.dart';
import 'calendar_local_datasource.dart';
import 'calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource localDataSource;

  const CalendarRepositoryImpl(this.localDataSource);

  @override
  Future<List<CalendarEvent>> getEvents() async {
    final cached = await localDataSource.getEvents();
    if (cached.isNotEmpty) return cached;
    return [];
  }

  @override
  Future<void> saveEvent(CalendarEvent event) {
    return localDataSource.saveEvent(event);
  }

  @override
  Future<void> deleteEvent(String id) {
    return localDataSource.deleteEvent(id);
  }
}
