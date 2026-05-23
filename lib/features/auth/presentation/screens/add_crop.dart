import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../crops/domain/crop.dart';
import '../../../crops/presentation/providers/crop_provider.dart';

class AddCropPage extends ConsumerStatefulWidget {
  const AddCropPage({super.key});

  @override
  ConsumerState<AddCropPage> createState() => _AddCropPageState();
}

class _AddCropPageState extends ConsumerState<AddCropPage> {
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _dateController = TextEditingController();
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().split('T').first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5EE),
      appBar: AppBar(
        title: const Text('Register New Crop'),
        backgroundColor: const Color(0xffF3F5EE),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEW ENTRY',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Register New Crop',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _field('Crop Name', _nameController),
              const SizedBox(height: 14),
              _field('Variety', _varietyController),
              const SizedBox(height: 14),
              _field('Planting Date', _dateController),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: _decoration('Status'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                    value: 'harvested',
                    child: Text('Harvested'),
                  ),
                  DropdownMenuItem(value: 'planned', child: Text('Planned')),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? 'active'),
              ),
              const SizedBox(height: 28),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Discard Draft',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                  onPressed: _saveCrop,
                  child: const Text(
                    'Register Crop',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return TextField(controller: controller, decoration: _decoration(label));
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _saveCrop() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Crop name is required.')));
      return;
    }
    final now = DateTime.now();
    await ref
        .read(cropRepositoryProvider)
        .saveCrop(
          Crop(
            id: now.microsecondsSinceEpoch.toString(),
            name: name,
            variety: _varietyController.text.trim().isEmpty
                ? 'General'
                : _varietyController.text.trim(),
            plantedDate: _dateController.text.trim(),
            status: _status,
          ),
        );
    ref.invalidate(cropsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Crop saved.')));
    context.pop();
  }
}
