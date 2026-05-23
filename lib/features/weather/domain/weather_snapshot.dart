class WeatherSnapshot {
  final String location;
  final String temperature;
  final String summary;
  final String updatedAt;

  const WeatherSnapshot({
    required this.location,
    required this.temperature,
    required this.summary,
    required this.updatedAt,
  });

  factory WeatherSnapshot.fromMap(Map<String, dynamic> map) {
    return WeatherSnapshot(
      location: map['location']?.toString() ?? 'Local Farm',
      temperature: map['temperature']?.toString() ?? '24°C',
      summary: map['summary']?.toString() ?? 'Offline forecast unavailable',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'location': location,
      'temperature': temperature,
      'summary': summary,
      'updated_at': updatedAt,
    };
  }
}
