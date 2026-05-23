import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../crops/domain/crop.dart';
import '../../../crops/presentation/providers/crop_provider.dart';

class HarvestPage extends ConsumerWidget {
  const HarvestPage({super.key});

  static const Color bgColor = Color(0xffF6F8F1);
  static const Color darkGreen = Color(0xff23692A);
  static const Color accentOrange = Color(0xffFF9800);
  static const Color textBrown = Color(0xff8D6E63);
  static const Color cardGrey = Color(0xffE9EDE0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsState = ref.watch(cropsProvider);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://api.dicebear.com/7.x/avataaars/png?seed=Felix&mouth=smile&eyebrows=default&eyes=default&clothing=graphicShirt&clothingColor=3c4d5b',
            ),
          ),
        ),
        title: const Text(
          "Organic Architect",
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Search saved.')));
            },
            icon: const Icon(Icons.search, color: Colors.grey),
          ),
          IconButton(
            onPressed: () => context.push('/settings_screen'),
            icon: const Icon(Icons.settings, color: darkGreen),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCropHeader(cropsState),
            const SizedBox(height: 25),
            _buildMaturityCard(cropsState),
            const SizedBox(height: 20),
            _buildInputSection(context),
            const SizedBox(height: 20),
            _buildLightInfoCard(),
            const SizedBox(height: 20),
            _buildStatsGrid(cropsState),
          ],
        ),
      ),
    );
  }

  Widget _buildCropHeader(AsyncValue<List<Crop>> cropsState) {
    return cropsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (crops) {
        if (crops.isEmpty) {
          return const Center(child: Text('No crops added yet.'));
        }
        final crop = crops.first;

        String statusText = 'GROWING';
        Color statusColor = Colors.green;

        if (crop.harvestTime != null) {
          final harvestDateParts = crop.harvestTime!.split('/');
          if (harvestDateParts.length == 3) {
            final harvestDate = DateTime(
              int.parse(harvestDateParts[2]),
              int.parse(harvestDateParts[1]),
              int.parse(harvestDateParts[0]),
            );
            final daysUntilHarvest = harvestDate
                .difference(DateTime.now())
                .inDays;
            if (daysUntilHarvest <= 0) {
              statusText = 'READY FOR HARVEST';
              statusColor = accentOrange;
            } else if (daysUntilHarvest <= 7) {
              statusText = 'NEAR HARVEST';
              statusColor = Colors.orange;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SECTOR 04 • HYDROPONIC BAY",
              style: TextStyle(
                color: textBrown,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMaturityCard(AsyncValue<List<Crop>> cropsState) {
    return cropsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (crops) {
        if (crops.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Center(child: Text('No crops added yet.')),
          );
        }
        final crop = crops.first;
        final plantedDate =
            DateTime.tryParse(crop.plantedDate) ?? DateTime.now();
        final daysSincePlanting = DateTime.now().difference(plantedDate).inDays;

        double progress = 0.5;
        String harvestInfo = 'No harvest date set';

        if (crop.harvestTime != null) {
          final harvestDateParts = crop.harvestTime!.split('/');
          if (harvestDateParts.length == 3) {
            final harvestDate = DateTime(
              int.parse(harvestDateParts[2]),
              int.parse(harvestDateParts[1]),
              int.parse(harvestDateParts[0]),
            );
            final totalDays = harvestDate.difference(plantedDate).inDays;
            progress = (daysSincePlanting / totalDays).clamp(0.0, 1.0);
            final daysUntilHarvest = harvestDate
                .difference(DateTime.now())
                .inDays;
            if (daysUntilHarvest <= 0) {
              harvestInfo = 'Ready for harvest!';
            } else {
              harvestInfo = '$daysUntilHarvest days until harvest';
            }
          }
        }

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
                "MATURITY PROGRESS",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        darkGreen,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        harvestInfo,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoColumn(title: "PLANTED", value: crop.plantedDate),
                  _InfoColumn(
                    title: "WATERING",
                    value: "EVERY ${crop.wateringIntervalDays} DAYS",
                    valueColor: textBrown,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stacked_line_chart, color: darkGreen),
              SizedBox(width: 8),
              Text(
                "Log Estimated Yield",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "WEIGHT (KG)",
            style: TextStyle(
              color: textBrown,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "00.00",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "QUALITY GRADE",
            style: TextStyle(
              color: textBrown,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text("Select Grade..."),
            items: const [],
            onChanged: (v) {},
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harvest entry saved.')),
                );
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                "Confirm Harvest Entry",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xffF5D9B1),
            child: Icon(Icons.wb_sunny, color: textBrown),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Optimal Harvest Light",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Lumen levels are perfect for picking. Lycopene synthesis is at peak.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AsyncValue<List<Crop>> cropsState) {
    return cropsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (crops) {
        if (crops.isEmpty) {
          return const Center(child: Text('No crops added yet.'));
        }
        final crop = crops.first;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildSmallStat("NUTRIENT EC", "2.4 mS"),
            _buildSmallStat("WATER PH", "5.8"),
            _buildSmallStat("PEST RISK", "Low", valueColor: Colors.green),
            _buildSmallStat("YIELD TREND", "+12%", valueColor: textBrown),
            _buildSmallStat("CROP TYPE", crop.name),
            _buildSmallStat("INTERVAL", "${crop.wateringIntervalDays} DAYS"),
          ],
        );
      },
    );
  }

  Widget _buildSmallStat(String title, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoColumn({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
