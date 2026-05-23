import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/crop_local_datasource.dart';
import '../../data/crop_repository.dart';
import '../../data/crop_repository_impl.dart';
import '../../domain/crop.dart';

final cropLocalDataSourceProvider = Provider<CropLocalDataSource>((ref) {
  return CropLocalDataSource();
});

final cropRepositoryProvider = Provider<CropRepository>((ref) {
  return CropRepositoryImpl(ref.watch(cropLocalDataSourceProvider));
});

final cropsProvider = FutureProvider<List<Crop>>((ref) async {
  return ref.watch(cropRepositoryProvider).getCrops();
});
