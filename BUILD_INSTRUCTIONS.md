# Build Instructions for Lost & Tossed

## Current Build Issues & Solutions

### 1. Run Code Generation
The project uses code generation for models. Run this command first:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Clean Build (if needed)
```bash
flutter clean
flutter pub get
```

### 4. Current Temporary Changes

Due to build conflicts, we've temporarily:
- Simplified models without JSON serialization
- Removed some complex provider dependencies
- Used basic enum implementations

### 5. Next Steps After Basic Build Works

1. Add back JSON serialization
2. Implement full model classes
3. Add complete service integrations
4. Run full code generation

## Build Order

1. `flutter pub get`
2. `dart run build_runner build`
3. `flutter run`

## Troubleshooting

If you encounter ML Kit conflicts:
- We've set compatible versions in pubspec.yaml
- Face detection: ^0.10.0
- Text recognition: ^0.13.0

If you encounter Provider conflicts:
- Ensure only flutter_riverpod Provider is used
- Check import order in files
