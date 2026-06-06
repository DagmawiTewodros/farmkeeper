import 'package:flutter_test/flutter_test.dart';
import 'package:farmkeeper/features/weather/domain/weather_snapshot.dart';

void main() {
  test('WeatherSnapshot toMap and fromMap roundtrip', () {
    final snapshot = WeatherSnapshot(
      location: 'Farm HQ',
      temperature: '18°C',
      summary: 'Cloudy with light showers',
      updatedAt: '2026-06-06 10:00',
    );

    final map = snapshot.toMap();
    final restored = WeatherSnapshot.fromMap(map);

    expect(restored.location, snapshot.location);
    expect(restored.temperature, snapshot.temperature);
    expect(restored.summary, snapshot.summary);
    expect(restored.updatedAt, snapshot.updatedAt);
  });
}
