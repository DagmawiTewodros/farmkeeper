import '../domain/calendar_event.dart';

abstract class CalendarRepository {
  Future<List<CalendarEvent>> getEvents();
  Future<void> saveEvent(CalendarEvent event);
  Future<void> deleteEvent(String id);
}
