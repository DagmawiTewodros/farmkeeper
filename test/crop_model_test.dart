import 'package:flutter_test/flutter_test.dart';
import 'package:farmkeeper/features/crops/domain/crop.dart';

void main() {
  test('Crop toMap and fromMap roundtrip', () {
    final crop = Crop(
      id: '1',
      name: 'Tomato',
      variety: 'Cherry',
      plantedDate: '2026-06-06',
      status: 'active',
      wateringIntervalDays: 4,
      harvestTime: '2 months',
    );

    final map = crop.toMap();
    final fromMap = Crop.fromMap(map);

    expect(fromMap.id, crop.id);
    expect(fromMap.name, crop.name);
    expect(fromMap.variety, crop.variety);
    expect(fromMap.plantedDate, crop.plantedDate);
    expect(fromMap.status, crop.status);
    expect(fromMap.wateringIntervalDays, crop.wateringIntervalDays);
    expect(fromMap.harvestTime, crop.harvestTime);
  });
}
