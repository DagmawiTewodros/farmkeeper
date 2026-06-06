import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmkeeper/features/calendar/domain/calendar_event.dart';
import 'package:farmkeeper/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:farmkeeper/features/journal/domain/journal_entry.dart';
import 'package:farmkeeper/features/journal/presentation/providers/journal_provider.dart';
import 'package:farmkeeper/features/calendar/data/calendar_repository.dart';
import 'package:farmkeeper/features/journal/data/journal_repository.dart';
import 'package:farmkeeper/features/tasks/domain/task.dart';
import 'package:farmkeeper/features/tasks/data/tasks_repository.dart';
import 'package:farmkeeper/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:farmkeeper/features/weather/data/weather_repository.dart';
import 'package:farmkeeper/features/weather/domain/weather_snapshot.dart';
import 'package:farmkeeper/features/weather/presentation/providers/weather_provider.dart';

class FakeTasksRepository implements TasksRepository {
  final List<Task> _tasks;
  FakeTasksRepository([List<Task>? tasks]) : _tasks = tasks ?? [];

  @override
  Future<void> addTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final matches = _tasks.where((task) => task.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<List<Task>> getTasks() async => List<Task>.from(_tasks);

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((element) => element.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }
}

class FakeWeatherRepository implements WeatherRepository {
  final WeatherSnapshot snapshot;

  FakeWeatherRepository(this.snapshot);

  @override
  Future<WeatherSnapshot> getWeather() async => snapshot;

  @override
  Future<void> saveWeather(WeatherSnapshot weather) async {}
}

class FakeJournalRepository implements JournalRepository {
  final List<JournalEntry> _entries;

  FakeJournalRepository([List<JournalEntry>? entries]) : _entries = entries ?? [];

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<List<JournalEntry>> getEntries() async => List<JournalEntry>.from(_entries);

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    _entries.add(entry);
  }
}

class FakeCalendarRepository implements CalendarRepository {
  final List<CalendarEvent> _events;

  FakeCalendarRepository([List<CalendarEvent>? events]) : _events = events ?? [];

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
  }

  @override
  Future<List<CalendarEvent>> getEvents() async => List<CalendarEvent>.from(_events);

  @override
  Future<void> saveEvent(CalendarEvent event) async {
    _events.add(event);
  }
}

void main() {
  test('tasksProvider returns list from repository', () async {
    final sampleTasks = [
      const Task(
        id: 'task_1',
        title: 'Water compost',
        subtitle: 'Keep humidity steady',
        priority: 'LOW',
        priorityColor: 'grey',
        timeOfDay: 'Afternoon',
      ),
    ];

    final container = ProviderContainer(overrides: [
      tasksRepositoryProvider.overrideWithValue(FakeTasksRepository(sampleTasks)),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(tasksProvider.future);
    expect(result, sampleTasks);
  });

  test('tasksProvider seeds default tasks when repository is empty', () async {
    final repository = FakeTasksRepository([]);
    final container = ProviderContainer(overrides: [
      tasksRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(tasksProvider.future);
    expect(result, isNotEmpty);
    expect(result.length, greaterThan(1));
    expect(result.any((task) => task.title.contains('Water Plot A-4')), isTrue);
  });

  test('weatherProvider returns snapshot from repository', () async {
    final snapshot = const WeatherSnapshot(
      location: 'Barn',
      temperature: '22°C',
      summary: 'Sunny',
      updatedAt: '2026-06-06 08:00',
    );
    final container = ProviderContainer(overrides: [
      weatherRepositoryProvider.overrideWithValue(FakeWeatherRepository(snapshot)),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(weatherProvider.future);
    expect(result.location, snapshot.location);
    expect(result.summary, snapshot.summary);
  });

  test('journalEntriesProvider returns entries from repository', () async {
    final entries = [
      const JournalEntry(
        id: 'entry_1',
        title: 'First harvest',
        note: 'Cucumbers are ready',
        createdAt: '2026-06-05',
      ),
    ];
    final container = ProviderContainer(overrides: [
      journalRepositoryProvider.overrideWithValue(FakeJournalRepository(entries)),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(journalEntriesProvider.future);
    expect(result, entries);
  });

  test('calendarEventsProvider returns events from repository', () async {
    final events = [
      const CalendarEvent(
        id: 'event_1',
        title: 'Irrigation check',
        eventDate: '2026-06-10',
        note: 'Inspect field 5',
      ),
    ];
    final container = ProviderContainer(overrides: [
      calendarRepositoryProvider.overrideWithValue(FakeCalendarRepository(events)),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(calendarEventsProvider.future);
    expect(result, events);
  });
}
