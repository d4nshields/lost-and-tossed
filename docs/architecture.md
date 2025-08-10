# Lost & Tossed - Architecture Documentation

## Overview

Lost & Tossed is a playful community field guide Flutter app for documenting found, discarded, or posted public objects. This document outlines the key architectural decisions made during development.

## Core Architecture Decisions

### 1. State Management: Riverpod

**Decision**: Use Riverpod for state management across the app.

**Rationale**:
- Type-safe provider system
- Excellent testing support
- Built-in caching and invalidation
- Compile-time safety
- Good performance characteristics

**Implementation**:
- Global providers for services (Supabase, location, etc.)
- Feature-specific providers for business logic
- UI state managed through StateNotifier when complex

### 2. Navigation: GoRouter

**Decision**: Use GoRouter for declarative routing and navigation.

**Rationale**:
- Type-safe route definitions
- Deep linking support out of the box
- Excellent support for nested routes (shell routes)
- Integrates well with Riverpod for auth state
- Better than Navigator 2.0 for complex routing scenarios

**Implementation**:
- Auth guard redirects implemented at router level
- Shell route for main app with bottom navigation
- Named routes for type safety

### 3. Feature-First Architecture

**Decision**: Organize code by features rather than layers.

**Rationale**:
- Better scalability as features grow
- Clearer separation of concerns
- Easier to find related code
- Supports team scaling (different developers can own features)

**Structure**:
```
lib/
├── features/           # Feature-specific code
│   ├── auth/
│   ├── capture/
│   ├── explore/
│   └── profile/
├── shared/            # Shared across features
│   ├── models/
│   └── widgets/
├── core/              # Core app infrastructure
│   ├── constants/
│   ├── errors/
│   ├── routing/
│   ├── scaffold/
│   └── theme/
└── services/          # External service integrations
```

### 4. Data Layer: Supabase

**Decision**: Use Supabase for backend services (auth, database, storage).

**Rationale**:
- Real-time capabilities out of the box
- Built-in auth with RLS (Row Level Security)
- PostgreSQL with full SQL support
- File storage with automatic CDN
- Good Flutter SDK
- Self-hostable if needed

**Implementation**:
- Repository pattern for data access
- RLS policies for data security
- Optimistic updates where appropriate

### 5. Privacy-First Design

**Decision**: Implement privacy controls at the data level.

**Rationale**:
- User trust is paramount
- Regulatory compliance (GDPR, CCPA)
- Community safety

**Implementation**:
- Coarse geohash for location (~2.4km precision)
- Exact location stored privately, optionally
- Face/license plate detection and blurring
- CC licensing options per submission
- Minimal telemetry

### 6. Geohash Library Selection

**Decision**: Use `dart_geohash` instead of the original `geohash` package.

**Rationale**:
- The original `geohash` package is not Dart 3 compatible (stuck at version 0.2.1)
- `dart_geohash` is actively maintained and Dart 3 compatible
- Provides both class-based and functional APIs
- Includes neighbor finding for area queries
- Better documentation and examples

**Implementation**:
- Coarse geohash (precision 5) for privacy: ~2.4km x 1.2km area
- Fine geohash (precision 7) for optional exact location: ~76m x 152m area
- Neighbor queries for finding items in surrounding areas
- Distance calculations for filtering false positives

## Technology Stack

### Core Framework
- **Flutter 3.16+**: Cross-platform mobile development
- **Dart 3.0+**: Programming language

### State Management & Navigation
- **Riverpod 2.4+**: State management and dependency injection
- **GoRouter 12.1+**: Declarative routing

### Backend & Data
- **Supabase**: Backend-as-a-Service (auth, database, storage)
- **PostgreSQL**: Database (via Supabase)
- **Row Level Security**: Data access control

### Location & Mapping
- **Geolocator**: Location services
- **dart_geohash**: Location privacy and indexing (Dart 3 compatible, actively maintained)

### Image Processing & ML
- **Google ML Kit**: Face detection and text recognition
- **Image package**: Image manipulation and optimization

### Code Generation
- **Freezed**: Immutable data classes
- **JSON Serializable**: JSON serialization

### Testing
- **Flutter Test**: Unit and widget testing
- **Golden Toolkit**: Golden file testing for UI
- **Mocktail**: Mocking for tests
- **Integration Test**: End-to-end testing

### Development Tools
- **Build Runner**: Code generation
- **Fastlane**: CI/CD for mobile deployment
- **GitHub Actions**: Continuous integration

## Data Models

### Core Entities

1. **LostItem**: Primary entity representing found objects
   - Supports 5 categories: Lost, Tossed, Posted, Marked, Curious
   - Includes privacy controls and licensing options

2. **AppUser**: User profile and preferences
   - Privacy settings
   - Contribution tracking

3. **Error Handling**: Comprehensive error types with user-friendly messages

## Development Principles

1. **Privacy by Design**: All features consider privacy implications first
2. **Progressive Enhancement**: Core features work without advanced permissions
3. **Playful but Respectful**: Fun micro-copy that's never judgmental
4. **Community-Focused**: Features designed to build positive community engagement
5. **Accessibility**: Inclusive design for all users
6. **Performance**: Efficient image handling and data loading

## Testing Strategy

1. **Unit Tests**: Core business logic and utilities
2. **Widget Tests**: UI components and screens
3. **Golden Tests**: Visual regression testing for key UI
4. **Integration Tests**: End-to-end user flows
5. **Repository Tests**: Data layer with mocked services

## Security Considerations

1. **Row Level Security**: Database-level access control
2. **Image Processing**: Automatic PII detection and blurring
3. **Location Privacy**: Coarse geohashing by default
4. **Minimal Data Collection**: Only collect what's necessary
5. **User Control**: Users control their data and privacy settings

## Future Considerations

1. **Offline Support**: Cache and sync when online
2. **Advanced ML**: Better PII detection, content moderation
3. **Community Features**: User interactions, comments
4. **Analytics**: Privacy-respecting usage analytics
5. **Accessibility**: Enhanced screen reader support, high contrast themes
