import '../domain/crop.dart';

abstract class CropRepository {
  Future<List<Crop>> getCrops();
  Future<void> saveCrop(Crop crop);
  Future<void> deleteCrop(String id);
}
