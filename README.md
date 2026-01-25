# Smart MotoNav 🏍️

Aplikasi navigasi motor pintar dengan prediksi konsumsi bahan bakar menggunakan AI (TensorFlow Lite) dan OpenStreetMap routing.

## ✨ Features

- 🧠 **AI-Powered Fuel Prediction** - Prediksi konsumsi BBM menggunakan TensorFlow Lite
- 🗺️ **Smart Routing** - Perhitungan rute optimal dengan OSRM
- ⏱️ **Real-time Traffic Score** - Perhitungan kondisi lalu lintas berdasarkan waktu
- 📱 **Cross-Platform** - Support Android & iOS
- 🎨 **Modern UI** - Material Design 3 dengan interactive map

## 🚀 Quick Start

### Prerequisites

- Flutter SDK ^3.9.2
- Android Studio / Xcode
- Device atau emulator

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

```
lib/
├── main.dart                                    # Entry point
└── features/
    └── navigation/
        ├── data/services/
        │   ├── fuel_prediction_service.dart     # AI Service
        │   └── osrm_service.dart                # Routing Service
        ├── providers/
        │   └── navigation_provider.dart         # State Management
        └── presentation/
            └── map_screen.dart                  # Map UI
```

## 🔧 Tech Stack

- **Framework:** Flutter 3.9.2
- **State Management:** Riverpod 2.5.1
- **AI Engine:** TensorFlow Lite 0.10.4
- **Maps:** FlutterMap 6.1.0 + OpenStreetMap
- **Routing:** OSRM API
- **GPS:** Geolocator 11.0.0

## 📚 Documentation

- [Technical Documentation](TECHNICAL_DOCUMENTATION.md) - Dokumentasi teknis lengkap untuk skripsi
- [Walkthrough](/.gemini/antigravity/brain/56822a66-c92f-4901-b0f9-503e7e2ba068/walkthrough.md) - Implementation walkthrough

## 🧪 Testing

```bash
# Run static analysis
flutter analyze

# Run tests (when available)
flutter test
```

## 📱 Screenshots

*Coming soon*

## 🛣️ Roadmap

- [ ] User profile management (CC motor, berat badan)
- [ ] GPS real-time tracking
- [ ] Multiple route options
- [ ] Fuel cost calculation
- [ ] Trip history & analytics
- [ ] Offline mode

## 📄 License

This project is created for academic purposes (Skripsi).

## 👨‍💻 Author

Miftahul - Smart MotoNav Project

---

**Built with ❤️ using Flutter & TensorFlow Lite**
