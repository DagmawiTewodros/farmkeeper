import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('AddCropPage saves crop and pops', (WidgetTester tester) async {
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
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // Open the AddCropPage via GoRouter
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Enter crop details
    final nameField = find.byType(TextField).at(0);
    final varietyField = find.byType(TextField).at(1);
    final dateField = find.byType(TextField).at(2);

    await tester.enterText(nameField, 'Tomato');
    await tester.enterText(varietyField, 'Cherry');
    await tester.enterText(dateField, '2026-06-06');

    await tester.tap(find.text('Register Crop'));
    await tester.pumpAndSettle();

    expect(fakeRepo.saved, isNotEmpty);
    expect(fakeRepo.saved.first.name, 'Tomato');

    // Should have popped back to initial screen
    expect(find.text('Open'), findsOneWidget);
  });
}
