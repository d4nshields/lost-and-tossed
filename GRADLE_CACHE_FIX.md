## 🔧 Gradle Cache Corruption Fix

The build error is caused by corrupted Gradle cache files for Google Play Services.

### ❌ **Problem:**
`play-services-location-21.2.0` cache is corrupted/missing manifest file.

### ✅ **Solution Steps:**

**1. Clean all caches completely:**
```bash
cd /home/daniel/work/lost-and-tossed

# Stop any Gradle daemons
./android/gradlew --stop

# Remove ALL Gradle caches (important!)
rm -rf ~/.gradle/caches/
rm -rf ~/.gradle/daemon/

# Clean Flutter build
flutter clean

# Clean Android build
cd android
./gradlew clean
cd ..
```

**2. Clear Android SDK cache:**
```bash
# Also clear Android SDK build cache if needed
rm -rf ~/.android/build-cache/
```

**3. Rebuild from scratch:**
```bash
# Get packages fresh
flutter pub get

# Try building again
flutter run lib/main_dev.dart
```

### 🔧 **Alternative: Force Gradle Refresh**

If the above doesn't work, try forcing dependency refresh:

```bash
cd android
./gradlew clean --refresh-dependencies
cd ..
flutter run lib/main_dev.dart
```

### 💡 **Why This Happens:**

- Gradle downloads dependencies and caches them
- Sometimes the download gets interrupted or corrupted
- The manifest file is missing from the cached dependency
- Clearing cache forces fresh download

### 🎯 **Expected Result:**

After clearing caches, Gradle will:
- ✅ Re-download all dependencies fresh
- ✅ Rebuild the cache properly
- ✅ Process manifests correctly
- ✅ Build successfully

Try the cache clearing commands above - this should resolve the manifest merger error!
