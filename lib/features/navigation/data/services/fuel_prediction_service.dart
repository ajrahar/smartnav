import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FuelPredictionService {
  Interpreter? _interpreter;

  // 1. Inisialisasi Model (Load File)
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/fuel_prediction_model.tflite',
      );
      debugPrint("AI Model Loaded Successfully!");
    } catch (e) {
      debugPrint("Error Loading Model: $e");
    }
  }

  // 2. Logic Mapping: Jam -> Skor Kemacetan (SAMA PERSIS DENGAN PYTHON)
  double _getTrafficScore(int hour) {
    // Skor 3.0 = Macet Parah (Pagi 7-9 & Sore 16-18)
    if ((hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 18)) {
      return 3.0;
    }
    // Skor 1.0 = Sepi (Malam 22 - Subuh 4)
    else if (hour >= 22 || hour <= 4) {
      return 1.0;
    }
    // Skor 2.0 = Normal (Siang hari)
    else {
      return 2.0;
    }
  }

  // 3. Fungsi Prediksi Utama
  Future<double> predict({
    required double distanceKm,
    required int ccMotor,
    required int weightKg,
  }) async {
    if (_interpreter == null) await loadModel();

    // A. Ambil Waktu Real-time
    int currentHour = DateTime.now().hour;

    // B. Konversi ke Skor
    double trafficScore = _getTrafficScore(currentHour);

    // C. Siapkan Input [1 baris, 4 kolom]
    // Urutan Wajib: [Jarak, CC, Skor, Berat]
    var input = [
      [distanceKm, ccMotor.toDouble(), trafficScore, weightKg.toDouble()],
    ];

    // D. Siapkan Output [1 baris, 1 kolom]
    var output = List.filled(1 * 1, 0.0).reshape([1, 1]);

    // E. Jalankan AI
    _interpreter!.run(input, output);

    // F. Ambil hasil (Liter)
    double resultLiter = output[0][0];

    // Debugging untuk memastikan logic berjalan
    debugPrint("--- AI PREDICTION LOG ---");
    debugPrint("Jam: $currentHour | Skor: $trafficScore");
    debugPrint("Input: $input");
    debugPrint("Output: $resultLiter Liter");

    return resultLiter;
  }

  // Cleanup
  void dispose() {
    _interpreter?.close();
  }
}
