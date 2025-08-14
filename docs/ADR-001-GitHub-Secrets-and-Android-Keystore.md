# ADR-001: GitHub Secrets and Android Keystore Configuration

**Date**: 2025-08-14  
**Status**: Accepted  
**Decision Makers**: Dan Shields  

## Context

The GitHub Actions deployment workflow requires secure handling of the Android release keystore. The workflow was failing because the generated `.p12` keystore file couldn't be found during the build process.

## Issue Analysis

1. **Secret Type**: Repository secrets vs Environment secrets confusion
2. **File Path**: Mismatch between keystore generation location and reference in `key.properties`

## Decision

### Use Repository Secrets (Current Approach is Correct)

**Repository Secrets** are appropriate for this use case because:
- Single keystore used across all deployment tracks (internal/alpha/beta/production)
- No need for environment-specific protection rules
- Simpler workflow without environment complexity
- Direct access to secrets in workflow without environment declaration

**Environment Secrets** would be needed if:
- Different keystores for different environments
- Required deployment approvals before production
- Environment-specific protection rules needed

### Fix File Path Issue

The root cause is a path mismatch:
- **Keystore created at**: `android/app/lost-and-tossed-upload-key.p12`
- **Referenced in key.properties as**: `storeFile=lost-and-tossed-upload-key.p12`
- **Expected by build.gradle**: `rootProject.file(keystoreProperties['storeFile'])`

Since `rootProject.file()` resolves relative to the `android/` directory, the path in `key.properties` should be `app/lost-and-tossed-upload-key.p12`.

## Implementation

### Option 1: Fix key.properties Generation (Recommended)
```yaml
- name: Create key.properties
  run: |
    echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=app/lost-and-tossed-upload-key.p12" >> android/key.properties
```

### Option 2: Move Keystore to Android Root
```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.RELEASE_KEYSTORE_BASE64 }}" | base64 --decode > android/lost-and-tossed-upload-key.p12
```

### Option 3: Use Absolute Path Resolution
```yaml
- name: Create key.properties
  run: |
    echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=../android/app/lost-and-tossed-upload-key.p12" >> android/key.properties
```

## Consequences

### Positive
- Maintains current repository secret configuration
- Fixes keystore file resolution
- Keeps build process simple and reliable
- No need to restructure workflow or create environments

### Negative
- None identified

## Security Considerations

- Repository secrets are appropriate for this single-environment use case
- Base64 encoding protects binary keystore data in secret storage
- Secrets are only exposed to authorized workflow runners
- Temporary files are cleaned up after workflow completion

## Monitoring

- Monitor workflow success/failure in GitHub Actions
- Verify app bundle builds successfully
- Confirm Play Store uploads work as expected

## Future Considerations

If the project grows to need:
- Separate staging/production keystores
- Deployment approval workflows
- Environment-specific configurations

Then consider migrating to GitHub Environments with environment-specific secrets.
