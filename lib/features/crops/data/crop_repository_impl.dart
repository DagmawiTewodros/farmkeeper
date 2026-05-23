import '../domain/crop.dart';
import 'crop_local_datasource.dart';
import 'crop_repository.dart';

class CropRepositoryImpl implements CropRepository {
  final CropLocalDataSource localDataSource;

  const CropRepositoryImpl(this.localDataSource);

  @override
  Future<List<Crop>> getCrops() async {
    final cached = await localDataSource.getCrops();
    if (cached.isNotEmpty) return cached;
    return [];
  }

  @override
  Future<void> saveCrop(Crop crop) {
    return localDataSource.saveCrop(crop);
  }

  @override
  Future<void> deleteCrop(String id) {
    return localDataSource.deleteCrop(id);
  }
}
