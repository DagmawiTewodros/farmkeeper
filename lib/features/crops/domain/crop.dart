class Crop {
  final String id;
  final String name;
  final String variety;
  final String plantedDate;
  final String status;
  final int wateringIntervalDays;
  final String? harvestTime;

  const Crop({
    required this.id,
    required this.name,
    required this.variety,
    required this.plantedDate,
    required this.status,
    this.wateringIntervalDays = 3,
    this.harvestTime,
  });

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      variety: map['variety']?.toString() ?? '',
      plantedDate: map['planted_date']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
      wateringIntervalDays: map['watering_interval_days'] is int
          ? map['watering_interval_days'] as int
          : int.tryParse(map['watering_interval_days']?.toString() ?? '3') ?? 3,
      harvestTime: map['harvest_time']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'variety': variety,
      'planted_date': plantedDate,
      'status': status,
      'watering_interval_days': wateringIntervalDays,
      'harvest_time': harvestTime,
    };
  }
}
