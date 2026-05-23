import '../domain/weather_snapshot.dart';
import 'weather_local_datasource.dart';
import 'weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherLocalDataSource localDataSource;

  const WeatherRepositoryImpl(this.localDataSource);

  @override
  Future<WeatherSnapshot> getWeather() async {
    final cached = await localDataSource.getWeather();
    if (cached != null) return cached;

    final fallback = WeatherSnapshot(
      location: 'Local Farm',
      temperature: '24°C',
      summary: 'Offline mode: weather uses locally cached/default data.',
      updatedAt: DateTime.now().toIso8601String(),
    );
    await localDataSource.saveWeather(fallback);
    return fallback;
  }

  @override
  Future<void> saveWeather(WeatherSnapshot weather) {
    return localDataSource.saveWeather(weather);
  }
}
