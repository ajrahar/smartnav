import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ccController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with current settings
    final settings = ref.read(settingsProvider);
    _ccController.text = settings.ccMotor.toString();
    _weightController.text = settings.weightKg.toString();
  }

  @override
  void dispose() {
    _ccController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final cc = int.parse(_ccController.text);
      final weight = int.parse(_weightController.text);

      await ref.read(settingsProvider.notifier).updateSettings(cc, weight);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes to keep UI in sync if updated elsewhere
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Kendaraan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profil Kendaraan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Data ini digunakan AI untuk memprediksi konsumsi BBM Anda lebih akurat.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // CC Motor Input
              TextFormField(
                controller: _ccController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Kapasitas Mesin (CC)",
                  border: OutlineInputBorder(),
                  suffixText: "cc",
                  prefixIcon: Icon(Icons.motorcycle),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi CC motor';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) return 'CC tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Weight Input
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Berat Badan Pengendara",
                  border: OutlineInputBorder(),
                  suffixText: "kg",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi berat badan';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) return 'Berat tidak valid';
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: settings.isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: settings.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan Pengaturan",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
