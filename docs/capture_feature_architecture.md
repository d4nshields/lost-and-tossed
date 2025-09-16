# Capture Feature Architecture

## Overview
The Capture feature allows users to document found objects with photos, categorization, and metadata. It follows clean architecture principles with clear separation between presentation, domain, and data layers.

## Database Schema

### Core Tables

#### submissions
Main table for all captured items:
- `id` (uuid): Primary key
- `user_id` (uuid): Foreign key to users table
- `category` (enum): lost, tossed, posted, marked, curious, traces
- `caption` (text): Optional playful caption
- `tags` (text[]): Array of tag names
- `license` (enum): CC_BY_NC (default) or CC0
- `disposed` (boolean): Whether item was cleaned up
- `geohash5` (text): 5-character geohash for coarse location
- `lat/lon` (float): Optional exact coordinates (private)
- `urls` (jsonb): Image URLs and variants
- `safety_flags` (jsonb): ML-detected privacy concerns
- `found_at` (timestamp): When the item was found
- `created_at` (timestamp): When submitted

#### traces
Special metadata for trace category submissions:
- `id` (uuid): Primary key
- `submission_id` (uuid): Foreign key to submissions
- `surface` (enum): soil, snow, pavement, glass, metal, wood, grass, other
- `freshness` (enum): minutes, hours, days
- `permanence` (enum): ephemeral, seasonal, semi_permanent
- `direction_deg` (float): Optional direction in degrees (0-359)
- `notes` (text): Additional observations

#### tags
Community-created tags:
- `id` (uuid): Primary key
- `name` (text): Unique tag name (alphanumeric with dashes/underscores)

## Feature Components

### Domain Layer (`/features/capture/domain`)

#### Models (`/models/submission_models.dart`)
- `Submission`: Main submission entity
- `TraceDetails`: Additional metadata for traces
- `Tag`: Tag entity
- `SubmissionDraft`: Local draft storage model
- Enums: `SubmissionCategory`, `LicenseType`, `TraceSurface`, `TraceFreshness`, `TracePermanence`

### Data Layer (`/features/capture/data`)

#### Repository (`capture_repository.dart`)
Handles all data operations:
- `getTags()`: Fetch available tags
- `createTag()`: Create new tag
- `submitCapture()`: Submit complete capture with image upload
- `saveDraft()`: Save to local storage
- `loadDraft()`: Load from local storage
- `clearDraft()`: Clear saved draft

### Presentation Layer (`/features/capture/presentation`)

#### Screens (`/screens/capture_screen.dart`)
Main capture screen with:
- Photo capture/selection
- Category picker with all 6 categories
- Dynamic trace details form
- Tag selection and creation
- Caption input with playful hints
- License selection (CC BY-NC/CC0)
- Disposal toggle
- Draft auto-save on app lifecycle

#### Widgets (`/widgets/trace_details_form.dart`)
Specialized form for trace category:
- Surface material selection
- Freshness estimation
- Permanence classification
- Optional direction input with compass helpers
- Additional notes field
- Pro tip display

### State Management (`/features/capture/providers`)

#### Providers (`capture_providers.dart`)
- `captureRepositoryProvider`: Repository instance
- `tagsProvider`: Available tags (async)
- `captureNotifierProvider`: Main state management
- `CaptureNotifier`: State notifier handling all capture logic
- `CaptureState`: Immutable state class

## Key Features

### Draft Persistence
- Automatic save on app pause/background
- Loads previous draft on screen initialization
- Clears draft after successful submission

### Image Handling
- Camera or gallery selection
- Image compression (1920x1920 max, 85% quality)
- Upload to Supabase storage
- Privacy blur processing (faces, plates, etc.)

### Location Privacy
- Stores only coarse geohash (5 precision ~5km)
- Exact coordinates optional and kept private
- No location exposed in public API

### Traces Category
Special handling for ephemeral marks:
- Additional metadata form
- Surface/freshness/permanence classification
- Direction tracking for movement traces
- Encourages wide + macro + scale photography

### Community Tags
- Pre-populated fun tags (shiny, tiny, mystery, colorful)
- Custom tag creation with validation
- Alphanumeric with dashes/underscores only

## Testing

### Golden Tests (`/test/features/capture/capture_screen_golden_test.dart`)
Visual regression tests for:
- Category selection states
- Trace form components
- Surface/freshness/permanence chips
- License selection

### Integration Test (`/integration_test/capture_flow_test.dart`)
End-to-end test covering:
- Complete capture flow
- Category switching behavior
- Trace form interaction
- Draft persistence

## Playful Micro-copy

The app maintains a curious, non-judgmental tone:
- "A glove begins its solo adventure"
- "Poster's still here, but the event is long gone"
- "The snack that left only a clue"
- "Wide shot + macro + scale object" (traces tip)

## Privacy & Ethics

- On-device ML blur for privacy (faces, plates, house numbers)
- Default CC BY-NC license, opt-in CC0
- Coarse location by default
- No ads or invasive telemetry
- Community-focused, not surveillance

## Future Enhancements

- OCR for found lists
- Offline mode with sync
- Bulk capture mode
- Time-lapse traces
- Seasonal comparisons
- Community challenges
