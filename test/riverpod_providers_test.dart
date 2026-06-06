import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmkeeper/features/crops/presentation/providers/crop_provider.dart';
import 'package:farmkeeper/features/crops/data/crop_repository.dart';
import 'package:farmkeeper/features/crops/domain/crop.dart';

class FakeRepo implements CropRepository {
  final List<Crop> _crops;
  FakeRepo(this._crops);

  @override
  Future<void> deleteCrop(String id) async {}

  @override
  Future<List<Crop>> getCrops() async => _crops;

  @override
  Future<void> saveCrop(Crop crop) async {}
}

void main() {
  test('cropsProvider returns list from repository', () async {
    final sample = [
      const Crop(id: '1', name: 'A', variety: 'v', plantedDate: '2026-06-06', status: 'active'),
    ];

    final container = ProviderContainer(overrides: [
      cropRepositoryProvider.overrideWithValue(FakeRepo(sample)),
    ]);

    addTearDown(container.dispose);

    final result = await container.read(cropsProvider.future);
    expect(result, sample);
  });
}
