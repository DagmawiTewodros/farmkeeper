import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/weather_local_datasource.dart';
import '../../data/weather_repository.dart';
import '../../data/weather_repository_impl.dart';
import '../../domain/weather_snapshot.dart';

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  return WeatherLocalDataSource();
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(ref.watch(weatherLocalDataSourceProvider));
});

final weatherProvider = FutureProvider<WeatherSnapshot>((ref) async {
  return ref.watch(weatherRepositoryProvider).getWeather();
});
