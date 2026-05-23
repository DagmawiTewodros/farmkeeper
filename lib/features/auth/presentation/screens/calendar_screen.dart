import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../crops/domain/crop.dart';
import '../../../crops/presentation/providers/crop_provider.dart';

class FarmKeeperPage extends ConsumerStatefulWidget {
  const FarmKeeperPage({super.key});

  @override
  ConsumerState<FarmKeeperPage> createState() => _FarmKeeperPageState();
}

class _FarmKeeperPageState extends ConsumerState<FarmKeeperPage> {
  final _cropTypeController = TextEditingController();
  final _plantDateController = TextEditingController();
  final _wateringIntervalController = TextEditingController(text: '3');
  DateTime? _selectedHarvestDate;

  @override
  void initState() {
    super.initState();
    _plantDateController.text = DateTime.now()
        .toIso8601String()
        .split('T')
        .first;
  }

  @override
  void dispose() {
    _cropTypeController.dispose();
    _plantDateController.dispose();
    _wateringIntervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crops',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications_screen'),
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF215A2A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Crop',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cropTypeController,
                      decoration: InputDecoration(
                        labelText: 'Crop Type',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _plantDateController,
                      decoration: InputDecoration(
                        labelText: 'Plant Date',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wateringIntervalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Watering Interval (days)',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedHarvestDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Harvest Time',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedHarvestDate != null
                                  ? '${_selectedHarvestDate!.day}/${_selectedHarvestDate!.month}/${_selectedHarvestDate!.year}'
                                  : 'Select harvest date',
                              style: TextStyle(
                                color: _selectedHarvestDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _addCrop(context),
                        child: const Text(
                          'Add Crop',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ref
                    .watch(cropsProvider)
                    .when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) =>
                          Center(child: Text(error.toString())),
                      data: (crops) {
                        if (crops.isEmpty) {
                          return const Center(
                            child: Text('No crops added yet.'),
                          );
                        }
                        return ListView.separated(
                          itemCount: crops.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final crop = crops[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.grass,
                                  color: Color(0xFF2E7D32),
                                ),
                                title: Text(crop.name),
                                subtitle: Text(
                                  '${crop.plantedDate} • ${crop.status}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _deleteCrop(context, crop.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCrop(BuildContext context) async {
    final cropType = _cropTypeController.text.trim();
    final interval = int.tryParse(_wateringIntervalController.text.trim()) ?? 3;
    if (cropType.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Crop type is required.')));
      return;
    }
    final now = DateTime.now();
    final harvestTimeString = _selectedHarvestDate != null
        ? '${_selectedHarvestDate!.day}/${_selectedHarvestDate!.month}/${_selectedHarvestDate!.year}'
        : null;
    await ref
        .read(cropRepositoryProvider)
        .saveCrop(
          Crop(
            id: now.microsecondsSinceEpoch.toString(),
            name: cropType,
            variety: 'General',
            plantedDate: _plantDateController.text.trim(),
            status: 'active',
            wateringIntervalDays: interval,
            harvestTime: harvestTimeString,
          ),
        );
    ref.invalidate(cropsProvider);
    _cropTypeController.clear();
    setState(() {
      _selectedHarvestDate = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Crop saved.')));
    }
  }

  Future<void> _deleteCrop(BuildContext context, String id) async {
    await ref.read(cropRepositoryProvider).deleteCrop(id);
    ref.invalidate(cropsProvider);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Crop deleted.')));
    }
  }
}
