# Google OAuth Setup Instructions

## Quick Overview

You need to configure OAuth in **two places**:
1. **Google Cloud Platform (GCP)** - Create OAuth clients
2. **Supabase** - Enable Google provider with credentials

**You do NOT need Firebase** for this setup - we're using Supabase Auth with Google Sign-In directly.

## Step-by-Step Setup

### 🔵 Phase 1: Google Cloud Platform

#### 1. Create a GCP Project
```
1. Go to: https://console.cloud.google.com
2. Click project dropdown → "New Project"
3. Name: "Lost and Tossed"
4. Click "Create"
```

#### 2. Configure OAuth Consent Screen
```
1. Left sidebar → "APIs & Services" → "OAuth consent screen"
2. Choose "External" → Create
3. Fill in:
   - App name: Lost & Tossed
   - User support email: [your email]
   - Developer contact: [your email]
4. Save and Continue
5. Add Scopes:
   - .../auth/userinfo.email
   - .../auth/userinfo.profile
6. Add test users (your email)
7. Save and Continue
```

#### 3. Create Web OAuth Client (REQUIRED)
```
1. "APIs & Services" → "Credentials"
2. "+ Create Credentials" → "OAuth client ID"
3. Type: "Web application"
4. Name: "Lost and Tossed Web Client"
5. Authorized JavaScript origins:
   https://itosryiospovqdcrnjxr.supabase.co
6. Authorized redirect URIs:
   https://itosryiospovqdcrnjxr.supabase.co/auth/v1/callback
7. Click "Create"
8. SAVE THESE:
   - Client ID: xxx.apps.googleusercontent.com
   - Client Secret: xxx
```

#### 4. Create Android OAuth Client
```
1. Get your SHA-1 fingerprint:
   cd /home/daniel/work/lost-and-tossed
   ./scripts/oauth_setup.sh
   Choose option 1

2. In GCP Credentials, create another OAuth client:
   - Type: "Android"
   - Name: "Lost and Tossed Android"
   - Package: com.tinkerplexlabs.lost_and_tossed
   - SHA-1: [paste your SHA-1]
3. Click "Create"
```

### 🟢 Phase 2: Supabase Configuration

#### 1. Enable Google Provider
```
1. Go to: https://supabase.com/dashboard
2. Select your project
3. "Authentication" → "Providers" → "Google"
4. Toggle ON
5. Enter:
   - Client ID: [Web Client ID from step 3]
   - Client Secret: [Web Client Secret from step 3]
6. Save
```

### 📱 Phase 3: Flutter App Configuration

#### 1. Update auth_repository.dart
```dart
// Replace this line in the GoogleSignIn constructor:
clientId: kIsWeb 
  ? 'YOUR_ACTUAL_WEB_CLIENT_ID.apps.googleusercontent.com'  // <-- Put your Web Client ID here
  : null,
```

#### 2. Create google-services.json
```bash
# Option A: Simple method (without Firebase)
cd /home/daniel/work/lost-and-tossed
./scripts/oauth_setup.sh
# Choose option 2 to create template
# Fill in the template with your values

# Option B: Download from Firebase Console (if you prefer)
# Only if you want to use Firebase for other features
```

#### 3. Install dependencies
```bash
flutter pub get
```

## Verification Checklist

Run this to check your setup:
```bash
cd /home/daniel/work/lost-and-tossed
./scripts/oauth_setup.sh
# Choose option 3
```

✅ Should have:
- [ ] Web OAuth Client ID and Secret from GCP
- [ ] Android OAuth Client with SHA-1 in GCP  
- [ ] Supabase Google provider enabled with Web credentials
- [ ] auth_repository.dart updated with Web Client ID
- [ ] google-services.json in android/app/ (optional but recommended)

## Common Issues & Solutions

### "Google sign-in was cancelled"
- Check Web Client ID is correctly set in auth_repository.dart
- Ensure package name matches: com.tinkerplexlabs.lost_and_tossed

### "Invalid OAuth client"
- Verify SHA-1 fingerprint matches
- Check you're using Web Client ID, not Android Client ID in Supabase

### "Redirect URI mismatch"
- Ensure Supabase URL in redirect URI matches your project
- Check for typos in the callback URL

### "Configuration not found"
- Make sure google-services.json is in android/app/
- Run `flutter clean && flutter pub get`

## Testing

1. Run the app:
```bash
flutter run
```

2. Tap "Continue with Google"
3. Select your Google account
4. Should redirect back to app and show Explore screen

## Security Notes

⚠️ **NEVER commit these to git:**
- google-services.json (add to .gitignore)
- OAuth Client Secret
- Any file with actual credentials

✅ **Safe to commit:**
- Client IDs (they're public)
- Supabase URL and anon key (they're public)

## Need Help?

1. Check Supabase logs: Dashboard → "Logs" → "Auth"
2. Check Android logs: `adb logcat | grep -i google`
3. Verify credentials: `./scripts/oauth_setup.sh` option 3

## Summary

The key insight is that you need **TWO** OAuth clients from GCP:
1. **Web Client** → Used by Supabase for the OAuth flow
2. **Android Client** → Used by the mobile app for Google Sign-In

The Web Client credentials go in Supabase, and the Android app uses both via the google-services.json file or direct configuration.
