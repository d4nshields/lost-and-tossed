# Lost & Tossed

A playful community field guide for documenting found, discarded, or posted public objects.

## Overview

Lost & Tossed is a mobile application that helps users document and share interesting objects they encounter in public spaces. The app focuses on building a community-driven map of our shared environment with a curious, kind, and non-judgmental approach.

## Project Status: MVP Database Schema Complete ✅

### Database Schema - FULLY IMPLEMENTED ✅
- ✅ **Supabase Database**: Complete schema matching exact requirements
- ✅ **Core Tables**: `users`, `submissions`, `lists`, `tags`, `submission_tags`
- ✅ **Exact Schema Match**: All table names, columns, and constraints per specification
- ✅ **RLS Policies**: `safety_flags.hidden != true` read policy, user ownership for writes
- ✅ **Seeded Data**: Common tags (shiny, tiny, mystery, colorful) pre-loaded
- ✅ **Idempotent Migrations**: Proper migration structure with documentation
- ✅ **Privacy-First Design**: Geohash for coarse location, optional exact coordinates
- ✅ **Moderation System**: Built-in content moderation via safety_flags
- ✅ **OCR Support**: Lists table for text recognition and correction

### Architecture & Core Setup
- ✅ **Flutter Project Structure**: Feature-first architecture
- ✅ **State Management**: Riverpod with providers for DI
- ✅ **Routing**: GoRouter with authentication guards
- ✅ **Theme System**: Material 3 design with custom color palette
- ✅ **Dependency Injection**: Clean service layer architecture

### Core Services
- ✅ **Supabase Service**: Database operations with error handling
- ✅ **Location Service**: GPS, geohash generation, privacy-conscious
- ✅ **Image Service**: ML Kit integration for face/text detection and blurring
- ✅ **Storage Service**: Supabase Storage for images and thumbnails

### UI Foundation
- ✅ **Main App Structure**: App initialization, error handling, theming
- ✅ **Navigation Shell**: Bottom navigation with floating action button
- ✅ **Screen Placeholders**: All main screens stubbed out
- ✅ **Loading States**: Professional loading and error screens

## Deployment

### GitHub Actions CI/CD

The project includes automated deployment to Google Play Store via GitHub Actions.

#### Prerequisites
1. Google Play Console account with app created
2. Service account with deployment permissions
3. Release keystore for app signing
4. Firebase project with `google-services.json`

#### Setup Instructions
1. Run the helper script to encode your files:
   ```bash
   bash scripts/prepare_github_secrets.sh
   ```

2. Add the following secrets to your GitHub repository:
   - `GOOGLE_SERVICES_JSON_BASE64` - Base64 encoded google-services.json
   - `RELEASE_KEYSTORE_BASE64` - Base64 encoded keystore file
   - `KEYSTORE_PASSWORD` - Keystore password
   - `KEY_PASSWORD` - Key password
   - `KEY_ALIAS` - Key alias (e.g., "upload")
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Service account JSON from Play Console

3. Create a release on GitHub or manually trigger the workflow

For detailed instructions, see [docs/DEPLOYMENT_SETUP.md](docs/DEPLOYMENT_SETUP.md)

## Features

### Categories
1. **Lost** 🧤 - Unintentionally left behind (gloves, keys, toys)
2. **Tossed** 🗑️ - Deliberately discarded (wrappers, cans, packaging)
3. **Posted** 📋 - Intended for display (flyers, posters, stickers)
4. **Marked** 🎨 - Non-removable markings (graffiti, stencils, chalk art)
5. **Curious** 🤔 - Anything else odd or unclassifiable

### Privacy Protection
- **Automatic Face Blurring**: ML Kit detects and blurs faces
- **Sensitive Text Detection**: License plates, house numbers, phone numbers
- **Location Privacy**: Stores coarse geohash (~152m precision) by default
- **Optional Exact Location**: Users can opt-in to share precise coordinates

### Tech Stack
- **Frontend**: Flutter with Riverpod state management
- **Backend**: Supabase (PostgreSQL + Auth + Storage + RLS)
- **Navigation**: GoRouter for type-safe routing
- **Image Processing**: Google ML Kit for privacy protection
- **Location**: Geolocator with geohash encoding
- **Testing**: Unit tests, widget tests, integration tests

## Next Steps

### Immediate (Next Session)
1. **Authentication Flow**: Complete login/signup with Supabase Auth
2. **Item Capture Flow**: Camera integration with privacy processing
3. **Home Screen**: Display items with infinite scroll and filtering
4. **Item Repository**: Riverpod providers for item management

### Short Term
1. **Item Detail Screen**: Full item view with comments and likes
2. **Search Functionality**: Text search with category filters
3. **Profile Management**: User profiles and settings
4. **Offline Support**: Local caching and sync

### Medium Term
1. **Map Integration**: Visual map of discoveries
2. **Push Notifications**: New items in your area
3. **Social Features**: Following users, activity feeds
4. **Advanced Moderation**: Community reporting and admin tools

## Database Schema

### Core Tables
- `users` - User profiles with unique handles
- `submissions` - Main content with privacy-conscious location storage
- `lists` - OCR text processing for found documents
- `tags` - Predefined and user-created tags
- `submission_tags` - Many-to-many tagging system

### Privacy Design
- Geohash precision 5 (~152m x 152m grid) for public location data
- Optional exact coordinates stored separately
- Automatic image processing to blur faces and sensitive text
- Row Level Security (RLS) policies for data access control

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build

# Run tests
flutter test

# Run app
flutter run
```

## Architecture Decisions

### 1. Feature-First Structure
```
lib/
├── core/           # App-wide configuration
├── features/       # Feature modules (auth, items, capture, profile)
├── shared/         # Shared components and services
```

### 2. Clean Architecture Layers
- **Presentation**: Riverpod providers, screens, widgets
- **Domain**: Business logic and models
- **Data**: Services for API, storage, location

### 3. Privacy by Design
- Default to coarse location (geohash level 5)
- Automatic detection and blurring of sensitive content
- User consent for exact location sharing
- Minimal data collection with clear purpose

### 4. Community-Driven Moderation
- User reporting system
- Content approval workflow
- Community guidelines enforcement
- Graduated response system

## Contributing

This is an MVP demonstrating clean Flutter architecture with Supabase backend. The codebase emphasizes:
- Type safety with comprehensive models
- Privacy protection through technical and design measures
- Scalable architecture supporting future feature additions
- Community-focused user experience design

## License

This project demonstrates modern Flutter development practices and architectural patterns for community-driven mobile applications.
