# Lost & Tossed 🔍📱

> A playful community field guide for documenting found, discarded, or posted public objects

Lost & Tossed is a Flutter mobile app that turns everyday observations into a shared community map. Document the gloves, posters, mysterious objects, and curious items you encounter in your daily life, creating a collective record of the world around us.

## ✨ Features

- **📸 Capture Objects**: Photo documentation with automatic privacy protection
- **🏷️ Smart Categorization**: Five intuitive categories for different types of finds
- **🗺️ Privacy-First Location**: Coarse location tracking that protects exact addresses
- **📄 Flexible Licensing**: Choose between CC BY-NC and CC0 for your contributions
- **🎨 Playful Interface**: Curious, kind, and never judgmental tone throughout
- **🔒 Privacy Controls**: Face/license plate detection with automatic blurring

## 📱 Categories

- **Lost** - Unintentionally left behind *(A glove begins its solo adventure)*
- **Tossed** - Deliberately discarded *(The snack that left only a clue)*
- **Posted** - Intended for display *(Poster's still here, but the event is long gone)*
- **Marked** - Non-removable markings *(Someone's creative mark on the world)*
- **Curious** - Odd or unclassifiable *(What story does this tell?)*

## 🚀 Getting Started

### Prerequisites

- Flutter 3.16.0 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (for iOS development) or Android Emulator

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/lost-and-tossed.git
   cd lost-and-tossed
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. **Generate code**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Environment Variables

Create a `.env` file in the project root with:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
ENABLE_ANALYTICS=false
```

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run integration tests
```bash
flutter test integration_test/
```

### Generate golden files
```bash
flutter test --update-goldens
```

## 🏗️ Architecture

Lost & Tossed follows a feature-first architecture with clean separation of concerns:

```
lib/
├── features/           # Feature modules (auth, capture, explore, profile)
├── shared/            # Shared models and widgets
├── core/              # App infrastructure (routing, theme, constants)
└── services/          # External service integrations
```

**Key Technologies:**
- **State Management**: Riverpod
- **Navigation**: GoRouter  
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Location**: Geolocator + dart_geohash (Dart 3 compatible)
- **Image ML**: Google ML Kit (face detection, text recognition)
- **Testing**: Flutter Test + Golden Toolkit

See [docs/architecture.md](docs/architecture.md) for detailed architectural decisions.

## 🔒 Privacy & Security

Lost & Tossed is designed with privacy as a core principle:

- **Location Privacy**: Uses coarse geohash (~2.4km precision) by default
- **Image Privacy**: Automatic face and license plate detection with blurring
- **Data Minimization**: Only collects necessary information
- **User Control**: Granular privacy settings for all features
- **Open Licensing**: Default CC BY-NC with CC0 option

## 🚀 Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Deploy via Fastlane
cd android && fastlane beta
```

### iOS

```bash
# Build iOS app
flutter build ios --release

# Deploy via Fastlane
cd ios && fastlane beta
```

## 🧰 Development Tools

### Code Generation
```bash
# Run code generation (models, routing)
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Code Quality
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run linter
dart run custom_lint
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`flutter test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📚 Documentation

- [Architecture Documentation](docs/architecture.md)
- [API Documentation](docs/api.md) *(coming soon)*
- [Deployment Guide](docs/deployment.md) *(coming soon)*

## 🐛 Issues & Support

- **Bug Reports**: [GitHub Issues](https://github.com/your-username/lost-and-tossed/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/your-username/lost-and-tossed/discussions)
- **Security Issues**: Email security@lostandtossed.app

## 🎯 Roadmap

- [ ] **V1.0**: Core capture and exploration features
- [ ] **V1.1**: Advanced search and filtering
- [ ] **V1.2**: Community features (favorites, sharing)
- [ ] **V1.3**: Offline support and sync
- [ ] **V2.0**: Enhanced ML detection and content moderation

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Google ML Kit for privacy-protecting image analysis
- The open source community for inspiration and tools

---

**Made with ❤️ and curiosity about the world around us**

*Remember: Every object has a story. What will you discover today?*
