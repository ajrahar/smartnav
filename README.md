# Smart MotoNav 🏍️

Smart MotoNav adalah aplikasi navigasi pintar khusus pengendara sepeda motor yang mengintegrasikan kecerdasan buatan (AI) untuk prediksi konsumsi bahan bakar secara real-time. Aplikasi ini membantu pengendara merencanakan perjalanan yang hemat energi dengan mempertimbangkan spesifikasi kendaraan dan beban pengendara.

## ✨ Features

- 🧠 **AI-Powered Fuel Prediction** - Prediksi konsumsi BBM menggunakan TensorFlow Lite yang dikustomisasi berdasarkan CC motor dan berat badan pengendara.
- 🗺️ **Smart Routing** - Perhitungan rute optimal dengan OSRM (Open Source Routing Machine) menggunakan data OpenStreetMap.
- ⚙️ **Personalized Settings** - Fitur pengaturan profil kendaraan (Kapasitas Mesin/CC & Berat Badan) untuk akurasi prediksi AI yang lebih tinggi.
- ⏱️ **Real-time Traffic Score** - Perhitungan estimasi durasi dan kondisi lalu lintas.
- 📱 **Cross-Platform** - Dikembangkan dengan Flutter untuk dukungan Android & iOS.
- 🎨 **Modern UI** - Antarmuka modern berbasis Material Design 3 dengan peta interaktif.

## 🚀 Quick Start

### Prerequisites

- Flutter SDK ^3.9.2
- Android Studio / Xcode
- Device Android/iOS atau Emulator

### Installation

```bash
# Clone repository
git clone <repository-url>
cd smartnav

# Install dependencies
flutter pub get

# Run app
flutter run
```

## 📁 Project Structure

Struktur project menggunakan pendekatan **Feature-First Architecture** untuk skalabilitas dan maintainability:

```
lib/
├── main.dart                                    # Entry point & App Config
└── features/
    ├── navigation/                              # Fitur Navigasi Utama
    │   ├── data/services/
    │   │   ├── fuel_prediction_service.dart     # AI Integration (TFLite)
    │   │   └── osrm_service.dart                # Routing Service (API)
    │   ├── providers/
    │   │   └── navigation_provider.dart         # State Management (Riverpod)
    │   └── presentation/
    │       └── map_screen.dart                  # UI Peta Navigasi
    └── settings/                                # Fitur Pengaturan Profil
        ├── data/
        │   └── settings_service.dart            # Local Storage
        ├── providers/
        │   └── settings_provider.dart           # State Management
        └── presentation/
            └── settings_screen.dart             # UI Input Data Kendaraan
```

## 🔧 Tech Stack

- **Framework:** Flutter 3.9.2 (Dart)
- **Architecture:** MVVM / Feature-First
- **State Management:** Riverpod 2.5.1
- **Artificial Intelligence:** TensorFlow Lite (On-device Machine Learning)
- **Maps & Location:** FlutterMap, latlong2, Geolocator
- **Routing API:** OSRM (Open Source Routing Machine)
- **Local Storage:** Shared Preferences

## 📚 Documentation

- [Technical Documentation](TECHNICAL_DOCUMENTATION.md) - Dokumentasi teknis mendalam untuk keperluan Skripsi/Tesis.

## 🧪 Testing

```bash
# Jalankan analisis statis kode
flutter analyze

# Jalankan unit test
flutter test
```

## 📸 Screenshots

*(Tambahkan screenshot aplikasi di sini)*

## 🛣️ Roadmap

- [x] Basic Navigation & Routing
- [x] AI Fuel Prediction Implementation
- [x] User Profile Management (Input CC Motor & Berat Badan)
- [ ] GPS Real-time Turn-by-turn Navigation
- [ ] Multi-route Selection (Eco vs Fastest)
- [ ] Trip History & Analytics
- [ ] Offline Map Support

## 📄 License

Project ini dibuat untuk tujuan akademis (Skripsi/Tugas Akhir).

## 👨‍💻 Author

**Miftahul** - Smart MotoNav Project

---
**Built with ❤️ using Flutter & TensorFlow Lite**
