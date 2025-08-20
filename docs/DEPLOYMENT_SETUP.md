# GitHub Actions Deployment Setup

This document explains how to set up the required GitHub secrets for automated deployment to Google Play Store.

## Required GitHub Secrets

You need to configure the following secrets in your GitHub repository settings (Settings → Secrets and variables → Actions):

### 1. **GOOGLE_SERVICES_JSON_BASE64**
The base64-encoded content of your `google-services.json` file from Firebase.

**How to create:**
```bash
# From the project root directory
base64 -w 0 android/app/google-services.json
```
Copy the output and add it as the secret value.

### 2. **RELEASE_KEYSTORE_BASE64**
The base64-encoded content of your Android release keystore file.

**How to create:**
```bash
# Assuming your keystore is named lost-and-tossed-upload-key.p12
base64 -w 0 path/to/lost-and-tossed-upload-key.p12
```

### 3. **KEYSTORE_PASSWORD**
The password for your keystore file.

### 4. **KEY_PASSWORD**
The password for the key within the keystore.

### 5. **KEY_ALIAS**
The alias of the key within the keystore (typically "upload" or similar).

### 6. **GOOGLE_PLAY_SERVICE_ACCOUNT_JSON**
The full JSON content of your Google Play Console service account credentials.

**How to obtain:**
1. Go to Google Play Console
2. Navigate to Setup → API access
3. Create or use existing service account
4. Download the JSON key file
5. Copy the entire JSON content (not base64 encoded)

## File Requirements

### google-services.json
This file is required for Google Sign-In functionality. It contains:
- Firebase project configuration
- OAuth client IDs
- API keys
- Package name configuration

**Important:** This file should never be committed to the repository. It's included in `.gitignore`.

### Keystore File
The release keystore is used to sign your app for production releases. 

**Security Note:** Never commit your keystore or its passwords to version control.

## Deployment Tracks

The workflow supports multiple deployment tracks:
- **internal**: For internal testing (default)
- **alpha**: For alpha testing
- **beta**: For closed beta testing
- **production**: For production release

Tracks are automatically selected based on git tags:
- `v1.0.0` → production
- `v1.0.0-beta.1` → beta
- `v1.0.0-alpha.1` → alpha
- `v1.0.0-rc.1` → beta (release candidate)
- Any other pattern → internal

## Testing the Workflow

### Manual Trigger
You can manually trigger the deployment workflow:
1. Go to Actions tab in GitHub
2. Select "Build and Deploy to Play Store"
3. Click "Run workflow"
4. Select the deployment track
5. Click "Run workflow"

### Automatic Trigger
The workflow automatically runs when you create a GitHub release.

## Troubleshooting

### Missing google-services.json Error
If you see this error:
```
File google-services.json is missing. The Google Services Plugin cannot function without it.
```

**Solution:** Ensure the `GOOGLE_SERVICES_JSON_BASE64` secret is properly configured.

### Keystore Errors
If you encounter signing errors:
1. Verify the keystore password and key password are correct
2. Ensure the key alias matches what's in your keystore
3. Check that the base64 encoding was done correctly

### Version Code Conflicts
The workflow uses timestamp-based version codes to avoid conflicts. Format: `YYMMDDHHMM`
- YY: Years since 2025 (00 for 2025, 01 for 2026, etc.)
- MMDDHHMM: Month, day, hour, minute in UTC

This ensures version codes always increase chronologically.

## Local Testing

To test the build locally without the secrets:
```bash
# Build debug APK (doesn't require signing)
flutter build apk --debug

# Build release APK (requires local google-services.json)
flutter build apk --release
```

## Security Best Practices

1. **Rotate secrets regularly** - Update your secrets periodically
2. **Limit access** - Only give repository admin access to trusted team members
3. **Use separate keys** - Use different keys for development and production
4. **Monitor usage** - Check GitHub Actions logs for unauthorized usage
5. **Backup securely** - Keep secure backups of your keystore and passwords

## Required Files Summary

| File | Location | In Git | GitHub Secret |
|------|----------|---------|---------------|
| google-services.json | android/app/ | ❌ | GOOGLE_SERVICES_JSON_BASE64 |
| Keystore (.p12/.jks) | N/A | ❌ | RELEASE_KEYSTORE_BASE64 |
| key.properties | android/ | ❌ | Created by workflow |

## Contact

For issues with deployment or access to secrets, contact the repository maintainer.
