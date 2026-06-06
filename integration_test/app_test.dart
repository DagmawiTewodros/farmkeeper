import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farmkeeper/features/auth/presentation/screens/add_crop.dart';
import 'package:farmkeeper/features/crops/data/crop_repository.dart';
import 'package:farmkeeper/features/crops/presentation/providers/crop_provider.dart';
import 'package:farmkeeper/features/crops/domain/crop.dart';

class FakeCropRepository implements CropRepository {
  List<Crop> saved = [];

  @override
  Future<void> deleteCrop(String id) async {}

  @override
  Future<List<Crop>> getCrops() async => [];

  @override
  Future<void> saveCrop(Crop crop) async {
    saved.add(crop);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration: add crop flow', (WidgetTester tester) async {
    final fakeRepo = FakeCropRepository();

    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () => context.push('/add'),
                child: const Text('Open'),
              );
            }),
          ),
        ),
      ),
      GoRoute(path: '/add', builder: (context, state) => const AddCropPage()),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [cropRepositoryProvider.overrideWithValue(fakeRepo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Carrot');
    await tester.enterText(find.byType(TextField).at(1), 'Nantes');
    await tester.enterText(find.byType(TextField).at(2), '2026-06-06');

    await tester.tap(find.text('Register Crop'));
    await tester.pumpAndSettle();

    expect(fakeRepo.saved, isNotEmpty);
    expect(fakeRepo.saved.first.name, 'Carrot');
  });
}
