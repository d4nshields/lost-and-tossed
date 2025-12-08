# Day 6: Image Upload Implementation

## Overview
Implemented a comprehensive image upload system with offline queue support using WorkManager for background processing. The system handles original, blurred, and thumbnail images with privacy protection and RLS compliance.

## Architecture Components

### 1. Models (`submission_models.dart`)
- **Submission**: Main model matching Supabase `submissions` table
- **Trace**: Metadata for trace category submissions  
- **SubmissionUrls**: Stores URLs for original, blurred, and thumbnail images
- **CreateSubmissionRequest**: Request model with optional trace fields
- **OfflineQueueItem**: Represents queued submissions for offline upload

### 2. Services

#### SubmissionService (`submission_service.dart`)
- Handles all Supabase database operations for submissions
- Creates submissions with automatic trace record creation for trace category
- Updates submission URLs and safety flags after image processing
- Implements user statistics and nearby submission queries

#### StorageService (`storage_service.dart`)
- Enhanced to handle three image versions:
  - **Original**: Stored privately if contains sensitive content
  - **Blurred**: Main display image with privacy protection applied
  - **Thumbnail**: Small preview image for lists
- Creates separate buckets for public and private storage
- Manages submission-specific folder structure

#### OfflineQueueService (`offline_queue_service.dart`)
- Manages offline queue using SharedPreferences
- Integrates with WorkManager for background upload tasks
- Implements retry logic with exponential backoff
- Handles image file persistence across app restarts
- Processes queue items when connectivity is restored

#### UploadManager (`upload_manager.dart`)
- Orchestrates the complete upload flow
- Coordinates between all services
- Handles connectivity detection and fallback to offline queue
- Provides unified interface for upload operations

### 3. Background Processing

#### WorkManager Integration
- **Periodic Sync**: Processes queue every 15 minutes when connected
- **One-off Tasks**: Immediate upload attempts for new submissions
- **Callback Dispatcher**: Handles background task execution
- **Constraints**: Only runs when network is available

## Database Schema Updates

### Submissions Table
```sql
- id: UUID primary key
- user_id: UUID (foreign key to users)
- category: ENUM (lost, tossed, posted, marked, curious, traces)
- caption: TEXT nullable
- tags: TEXT[] nullable
- geohash5: TEXT (5 character geohash)
- lat/lon: FLOAT nullable (exact coordinates)
- urls: JSONB (stores original, blurred, thumbnail URLs)
- license: ENUM (CC_BY_NC, CC0)
- disposed: BOOLEAN
- found_at: TIMESTAMP
- safety_flags: JSONB
- created_at: TIMESTAMP
```

### Traces Table
```sql
- id: UUID primary key
- submission_id: UUID (foreign key, unique)
- surface: ENUM (soil, snow, pavement, etc.)
- freshness: ENUM nullable (minutes, hours, days)
- direction_deg: FLOAT nullable
- permanence: ENUM nullable (ephemeral, seasonal, semi_permanent)
- notes: TEXT nullable
- created_at/updated_at: TIMESTAMPS
```

## Privacy Protection Flow

1. **Client-side Processing**:
   - ML Kit detects faces and sensitive text
   - Applies Gaussian blur to sensitive regions
   - Generates privacy report

2. **Storage Strategy**:
   - If no sensitive content: original stored publicly
   - If sensitive content: original stored privately, blurred version public
   - Thumbnail always generated from processed image

3. **Safety Flags**:
   - Records number of faces/text blurred
   - Marks as client-processed
   - Server can perform additional checks

## Offline Queue Implementation

### Queue Storage
- Uses SharedPreferences for persistence
- Stores serialized JSON of queue items
- Maintains retry count and error messages

### Retry Logic
- Maximum 3 retries per item
- Exponential backoff between attempts
- Failed items removed after max retries
- Temporary image files cleaned up

### Background Upload Flow
1. Check connectivity
2. Process image for privacy
3. Create submission in database
4. Upload images to storage
5. Update submission with URLs
6. Remove from queue on success

## RLS (Row Level Security) Compliance

### Implemented Policies
1. **Users can only modify their own submissions**
   - DELETE requires user_id match
   - UPDATE requires user_id match

2. **All users can read non-disposed submissions**
   - SELECT allowed for disposed = false

3. **Anonymous users cannot create submissions**
   - INSERT requires authentication

4. **Traces follow submission ownership**
   - CASCADE delete with submissions
   - Read access tied to submission visibility

### Test Coverage
Created comprehensive RLS compliance tests in `rls_compliance_test.dart`:
- User ownership verification
- Anonymous access prevention
- Cascade deletion testing
- Read permission validation

## Android Permissions

Added required permissions in `AndroidManifest.xml`:
```xml
<!-- Storage for temporary image files -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Background work -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

## Dependencies Added

```yaml
workmanager: ^0.5.2  # Background task management
connectivity_plus: ^5.0.2  # Network connectivity detection
```

## Usage Example

```dart
// Initialize background processing on app start
await OfflineQueueService.initialize();

// Upload a submission
final uploadManager = UploadManager(
  logger: logger,
  submissionService: submissionService,
  storageService: storageService,
  imageService: imageService,
  offlineQueueService: offlineQueueService,
  locationService: locationService,
);

final result = await uploadManager.uploadSubmission(
  category: SubmissionCategory.traces,
  imageFile: capturedImage,
  caption: "Footprints in fresh snow",
  tags: ['winter', 'footprints'],
  license: LicenseType.ccByNc,
  // Trace-specific fields
  traceSurface: TraceSurface.snow,
  traceFreshness: TraceFreshness.minutes,
  tracePermanence: TracePermanence.ephemeral,
);

if (result.isSuccess) {
  // Show success message
} else if (result.isQueued) {
  // Inform user submission is queued
} else {
  // Handle error
}
```

## Testing Recommendations

1. **Unit Tests**:
   - Test each service method independently
   - Mock Supabase client and verify RLS compliance
   - Test offline queue serialization/deserialization

2. **Integration Tests**:
   - Test complete upload flow with real Supabase
   - Verify image processing and storage
   - Test offline to online transition

3. **Golden Tests**:
   - Create golden images for upload status UI
   - Test privacy blur visualization
   - Verify trace metadata form rendering

## Next Steps

1. **UI Implementation**:
   - Create upload progress indicators
   - Build offline queue management UI
   - Add retry/cancel options for queued items

2. **Server-side Processing**:
   - Implement additional privacy checks
   - Add image moderation
   - Generate alternative thumbnails

3. **Analytics**:
   - Track upload success rates
   - Monitor queue processing times
   - Analyze privacy protection effectiveness

## Performance Considerations

- Image processing is done asynchronously
- Thumbnails reduce bandwidth for list views
- Offline queue prevents data loss
- Background uploads preserve battery life
- Geohash indexing enables efficient location queries

## Security Notes

- Original images with sensitive content stored privately
- Client-side blurring provides immediate privacy
- Server can perform additional validation
- RLS ensures users can only modify own content
- Temporary files cleaned up after processing
