import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/themes.dart';
import '../../../crops/domain/crop.dart';
import '../../../crops/presentation/providers/crop_provider.dart';

class WateringPage extends ConsumerWidget {
  const WateringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsState = ref.watch(cropsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildCropFocusCard(context, cropsState),
            const SizedBox(height: 24),
            _buildIntervalsSection(cropsState),
            const SizedBox(height: 24),
            _buildHydrationHealthCard(),
            const SizedBox(height: 24),
            _buildRecentHistorySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://api.dicebear.com/7.x/avataaars/png?seed=Felix&mouth=smile&eyebrows=default&eyes=default&clothing=graphicShirt&clothingColor=3c4d5b',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        "Organic Architect",
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/settings_screen'),
          icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildCropFocusCard(
    BuildContext context,
    AsyncValue<List<Crop>> cropsState,
  ) {
    return cropsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (crops) {
        if (crops.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardGrey,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Center(child: Text('No crops added yet.')),
          );
        }
        final crop = crops.first;
        final nextWatering = _calculateNextWatering(crop);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardGrey,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CROP FOCUS",
                style: TextStyle(
                  color: AppColors.accentBrown,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                crop.name,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Watering interval: ${crop.wateringIntervalDays} days. Planted on ${crop.plantedDate}.",
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Watering recorded.')),
                  );
                },
                icon: const Icon(Icons.opacity, color: Colors.white),
                label: const Text(
                  "Mark as Watered",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.accentBrown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "NEXT: $nextWatering",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _calculateNextWatering(Crop crop) {
    final plantedDate = DateTime.tryParse(crop.plantedDate) ?? DateTime.now();
    final nextWatering = plantedDate.add(
      Duration(days: crop.wateringIntervalDays),
    );
    return '${nextWatering.month}/${nextWatering.day}';
  }

  Widget _buildIntervalsSection(AsyncValue<List<Crop>> cropsState) {
    return cropsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (crops) {
        if (crops.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Center(child: Text('No crops added yet.')),
          );
        }
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Watering\nIntervals",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Text(
                    "CROP\nBASED",
                    style: TextStyle(
                      color: AppColors.accentBrown,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...crops.map(
                (crop) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _intervalTile(
                    crop.wateringIntervalDays.toString(),
                    "${crop.name.toUpperCase()} - EVERY ${crop.wateringIntervalDays} DAYS",
                    false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _intervalTile(String number, String label, bool isSelected) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.transparent : AppColors.cardGrey,
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationHealthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text(
            "Hydration Health",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 12,
                  backgroundColor: AppColors.cardGrey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const Column(
                children: [
                  Text(
                    "75%",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "OPTIMAL RANGE",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Based on current soil sensors and last\nwatering cycle.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistorySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                "Recent History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _historyItem(
            "Aug 22, 2023",
            "Manual: 4.2 Liters",
            "YESTERDAY",
            Icons.check_circle_outline,
          ),
          _historyItem(
            "Aug 20, 2023",
            "Auto: 4.5 Liters",
            "3 DAYS AGO",
            Icons.autorenew,
          ),
          _historyItem(
            "Aug 18, 2023",
            "Auto: 4.5 Liters",
            "5 DAYS AGO",
            Icons.autorenew,
          ),
        ],
      ),
    );
  }

  Widget _historyItem(
    String date,
    String subtitle,
    String timeAgo,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.cardGrey,
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
