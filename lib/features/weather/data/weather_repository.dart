import '../domain/weather_snapshot.dart';

abstract class WeatherRepository {
  Future<WeatherSnapshot> getWeather();
  Future<void> saveWeather(WeatherSnapshot weather);
}
