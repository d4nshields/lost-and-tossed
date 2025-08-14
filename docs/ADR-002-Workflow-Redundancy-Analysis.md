# ADR-002: Workflow Redundancy Analysis - Release vs Deploy

**Date**: 2025-08-14  
**Status**: Accepted  
**Decision Makers**: Dan Shields  

## Context

The project currently has two GitHub Actions workflows that both trigger on `release` events:
1. `release.yml` - "Release & Deploy" 
2. `deploy.yml` - "Build and Deploy to Play Store"

This creates redundancy and potential conflicts when releases are published.

## Analysis

### release.yml Capabilities
- ✅ **Builds**: App Bundle (.aab) and APK
- ✅ **Testing**: None
- ✅ **Artifacts**: Uploads to GitHub release page and workflow artifacts
- ✅ **Versioning**: Uses custom Dart script (`scripts/generate_version.dart`)
- ✅ **Manual Trigger**: workflow_dispatch with version name input
- ❌ **Play Store Deploy**: Commented out (future implementation)
- ✅ **Keystore Handling**: Correct path (`app/lost-and-tossed-upload-key.p12`)

### deploy.yml Capabilities  
- ✅ **Builds**: App Bundle (.aab) only
- ✅ **Testing**: Full test suite (analyze, unit tests, widget tests)
- ❌ **Artifacts**: None (only deploys to Play Store)
- ✅ **Versioning**: Inline timestamp-based version code generation
- ✅ **Manual Trigger**: workflow_dispatch with deployment track selection
- ✅ **Play Store Deploy**: Full implementation with track selection
- ❌ **Keystore Handling**: Incorrect path (missing `app/` prefix) - **FIXED**

### Key Differences

| Feature | release.yml | deploy.yml |
|---------|-------------|------------|
| **Primary Purpose** | Build & Archive | Test & Deploy |
| **Testing** | None | Comprehensive |
| **Play Store** | Future/Manual | Automated |
| **Track Selection** | No | Yes (internal/alpha/beta/production) |
| **GitHub Artifacts** | Yes | No |
| **Version Script** | Dart script | Inline bash |
| **Keystore Path** | Correct | Fixed in this ADR |

## Decision

**Keep both workflows but clarify their distinct purposes:**

### release.yml → Rename to `build-release.yml`
- **Purpose**: Build and archive release artifacts
- **Trigger**: Manual workflow_dispatch only (remove release trigger)
- **Use Case**: When you want to build release artifacts without deploying
- **Outputs**: GitHub release assets, workflow artifacts for QA testing

### deploy.yml → Keep as is
- **Purpose**: Complete CI/CD pipeline with testing and deployment
- **Trigger**: Release events (automatic deployment) + manual workflow_dispatch
- **Use Case**: Full automated deployment pipeline
- **Outputs**: Apps deployed to Google Play Store

## Implementation

### 1. Update release.yml

```yaml
name: Build Release Artifacts

on:
  workflow_dispatch:
    inputs:
      version_name:
        description: 'Version name (e.g., 0.1.0)'
        required: true
        default: '0.1.0'
      create_github_release:
        description: 'Create GitHub release'
        type: boolean
        default: false

# Remove release trigger, keep build logic
```

### 2. Update deploy.yml

```yaml
# Fix keystore path issue:
- name: Create key.properties
  run: |
    echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=app/lost-and-tossed-upload-key.p12" >> android/key.properties
```

## Workflow Decision Tree

```
Release Event Triggered
    ↓
deploy.yml runs:
    ↓
1. Run Tests (analyze, unit, widget)
    ↓
2. Build App Bundle
    ↓
3. Deploy to appropriate Play Store track
    ↓
4. Success ✅

Manual Build Needed (for QA/testing)
    ↓
Manually trigger build-release.yml:
    ↓
1. Build App Bundle + APK
    ↓
2. Upload to GitHub artifacts
    ↓
3. Optionally create GitHub release
    ↓
4. Artifacts available for download ✅
```

## Consequences

### Positive
- **Clear separation of concerns**: Build vs Deploy
- **No redundant execution** on release events
- **Flexibility**: Can build without deploying, or deploy without manual builds
- **Testing**: All deployments go through full test suite
- **Track management**: Proper Play Store track selection

### Negative
- **Complexity**: Two workflows to maintain instead of one
- **Learning curve**: Team needs to understand when to use which workflow

### Risks Mitigated
- **Double deployment**: Would have caused Play Store conflicts
- **Untested releases**: Manual builds skip testing, deployments don't
- **Version conflicts**: Different version generation methods could clash

## Alternatives Considered

### 1. Single Unified Workflow
**Rejected**: Too complex, mixing concerns of building vs deploying

### 2. Delete release.yml
**Rejected**: Loses ability to build artifacts without deploying

### 3. Delete deploy.yml  
**Rejected**: Loses automated testing and sophisticated track management

## Future Considerations

- Consider adding automated integration tests to deploy.yml
- Monitor workflow execution times and optimize caching
- Evaluate need for staging environment workflow
- Consider adding security scanning to the deployment pipeline

## Migration Steps

1. ✅ Fix keystore path in deploy.yml (immediate)
2. Rename release.yml to build-release.yml
3. Remove release trigger from build-release.yml
4. Update documentation
5. Test both workflows in isolation
6. Communicate changes to team

## Monitoring

- Watch for any double-execution issues during migration
- Monitor Play Store deployment success rates
- Verify artifact generation works correctly
- Ensure no releases are missed due to workflow changes
