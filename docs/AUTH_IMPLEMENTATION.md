# Authentication Implementation

## Overview
Lost & Tossed uses Supabase Auth with Google Sign-In for user authentication. The implementation includes automatic user profile creation, unique handle generation, and session-based route protection.

## Setup Requirements

### 1. Google OAuth Configuration
You need to set up Google OAuth credentials:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials
5. Add your SHA-1 fingerprint for Android

### 2. Android Configuration
Add your Google Services configuration:

```bash
# Place google-services.json in:
android/app/google-services.json
```

### 3. Supabase Configuration
The Supabase project needs:
- Google OAuth provider enabled in Authentication settings
- Database triggers for user profile creation (already set up via migration)

## Features Implemented

### ✅ Authentication
- [x] Google Sign-In integration
- [x] Supabase Auth setup
- [x] Session management with Riverpod
- [x] Auth state persistence
- [x] Sign out functionality

### ✅ User Management
- [x] Automatic profile creation on first login
- [x] Unique handle generation (explorer_XXXXX format)
- [x] Profile data model
- [x] Avatar URL from Google account
- [x] Email storage (private)

### ✅ Navigation & Guards
- [x] SessionGuard for route protection
- [x] Auth-aware router with redirects
- [x] Three-tab bottom navigation (Explore, Capture, Notebook)
- [x] Login screen with branding
- [x] Loading states during auth check

### ✅ UI Components
- [x] Login screen with micro-copy
- [x] Explore screen with Map/Feed tabs
- [x] Capture screen with category selection
- [x] Notebook screen for user's finds
- [x] User profile display in navigation

### ✅ Database Schema
- [x] Users table with RLS policies
- [x] Handle generation function
- [x] Auth trigger for new users
- [x] Profile fields (handle, email, avatar_url, bio)

### ✅ Testing
- [x] Auth redirect tests
- [x] New user bootstrap tests
- [x] Integration test structure

## Project Structure

```
lib/features/auth/
├── domain/
│   └── models/
│       └── user_profile.dart      # User profile model
├── data/
│   └── auth_repository.dart       # Auth operations
├── providers/
│   └── auth_providers.dart        # Riverpod providers
└── presentation/
    └── login_screen.dart           # Login UI

lib/features/explore/
└── presentation/
    └── screens/
        └── explore_screen.dart     # Map + Feed tabs

lib/features/capture/
└── presentation/
    └── screens/
        └── capture_screen.dart     # Capture UI

lib/features/notebook/
└── presentation/
    └── screens/
        └── notebook_screen.dart    # User's finds

lib/core/
├── router/
│   └── app_router.dart            # Navigation + guards
└── di/
    └── providers.dart              # Core providers
```

## Usage

### Sign In Flow
```dart
// User taps "Continue with Google"
ref.read(authNotifierProvider.notifier).signInWithGoogle();

// Auth state automatically updates
// Router redirects to home on success
```

### Check Auth State
```dart
// In a ConsumerWidget
final user = ref.watch(authUserProvider).value;
final isAuthenticated = user != null;

// Or use the extension
final isAuthenticated = ref.isAuthenticated;
final userId = ref.currentUserId;
```

### Get User Profile
```dart
final profileAsync = ref.watch(currentUserProfileProvider);

profileAsync.when(
  data: (profile) => Text('@${profile.handle}'),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error loading profile'),
);
```

### Sign Out
```dart
ref.read(authNotifierProvider.notifier).signOut();
```

## Testing

Run tests with:
```bash
# Unit tests
flutter test test/features/auth/

# Integration tests
flutter test integration_test/
```

## Next Steps

1. **Add Google Services**
   - Set up Firebase project
   - Add google-services.json
   - Configure OAuth consent screen

2. **Enhance Profile**
   - Add profile editing
   - Handle change functionality
   - Avatar upload to Supabase Storage

3. **Add Social Features**
   - Follow/following system
   - User discovery
   - Activity feed

4. **Implement Capture Logic**
   - Image upload to Supabase Storage
   - Privacy blur detection
   - Geolocation handling
   - Submission creation

5. **Build Feed/Map**
   - Real-time updates
   - Location-based queries
   - Category filtering
   - Search functionality

## Security Notes

- All tables use Row Level Security (RLS)
- Users can only modify their own data
- Exact coordinates are kept private (only geohash public)
- Email addresses are not publicly visible
- Auth tokens managed securely by Supabase SDK

## Troubleshooting

### Google Sign-In Issues
- Ensure SHA-1 fingerprint is added to Firebase
- Check package name matches Firebase config
- Verify OAuth consent screen is configured

### Profile Not Created
- Check database trigger is active
- Verify RLS policies allow insert
- Check Supabase logs for errors

### Navigation Issues
- Clear app data and restart
- Check router redirect logic
- Verify auth state stream is working
