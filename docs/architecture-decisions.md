# Architecture Decision Records (ADRs)

This document tracks the key architectural decisions made during the development of Lost & Tossed.

## ADR-001: Database Schema Design

**Date**: 2025-01-19
**Status**: Accepted

### Context
We need a database schema that supports community-driven content with strong privacy protections and moderation capabilities.

### Decision
- Use Supabase PostgreSQL with Row Level Security (RLS)
- Store location data as geohash (precision 5 ≈ 152m) for privacy
- Separate exact coordinates as optional, private field
- Include comprehensive moderation system with reports table
- Use full-text search with tsvector for performance

### Consequences
- **Positive**: Strong privacy protection, scalable search, community moderation
- **Negative**: Slightly more complex location queries
- **Mitigation**: Helper functions for geohash operations

## ADR-002: State Management with Riverpod

**Date**: 2025-01-19
**Status**: Accepted

### Context
Need reliable state management for Flutter app with complex data flows and dependency injection.

### Decision
- Use Riverpod 2.x as primary state management solution
- Implement providers for all services (DI)
- Use AsyncProvider for data fetching
- Stream providers for real-time auth state

### Consequences
- **Positive**: Type-safe DI, excellent testing support, reactive UI updates
- **Negative**: Learning curve for Riverpod-specific patterns
- **Mitigation**: Comprehensive provider documentation and examples

## ADR-003: Privacy-First Image Processing

**Date**: 2025-01-19
**Status**: Accepted

### Context
Users will photograph public spaces that may contain faces, license plates, or other sensitive information.

### Decision
- Integrate Google ML Kit for on-device processing
- Automatically detect and blur faces
- Detect sensitive text patterns (license plates, house numbers, phone numbers)
- Process images before upload, never store unprocessed originals
- Provide user feedback about privacy protections applied

### Consequences
- **Positive**: Strong privacy protection, user trust, legal compliance
- **Negative**: Increased app complexity, processing time, larger app size
- **Mitigation**: Clear UI feedback, optional manual review

## ADR-004: Feature-First Project Structure

**Date**: 2025-01-19
**Status**: Accepted

### Context
Need scalable project organization that supports team development and feature isolation.

### Decision
```
lib/
├── core/           # App-wide config, DI, routing, theme
├── features/       # Feature modules (auth, items, capture, profile)
│   └── feature/    # Each feature has domain, data, presentation
├── shared/         # Shared models, widgets, services
```

### Consequences
- **Positive**: Clear feature boundaries, scalable team development, testable modules
- **Negative**: More initial setup, potential code duplication
- **Mitigation**: Shared utilities and clear inter-feature communication patterns

## ADR-005: Location Privacy Strategy

**Date**: 2025-01-19
**Status**: Accepted

### Context
Location data is sensitive but essential for the app's core functionality.

### Decision
- Default to geohash precision 5 (~152m x 152m grid) for public data
- Store exact coordinates separately with user consent
- Allow users to manually adjust location or use approximate location
- Never require exact location for app functionality

### Consequences
- **Positive**: Privacy protection, regulatory compliance, user trust
- **Negative**: Less precise location features, complex location handling
- **Mitigation**: Clear privacy controls, optional precision improvements

## ADR-006: Community Moderation System

**Date**: 2025-01-19
**Status**: Accepted

### Context
User-generated content requires moderation while maintaining community spirit.

### Decision
- All content starts as "pending" status
- Community reporting system with structured reasons
- Automated approval for trusted users (future)
- Appeal process for rejected content
- Graduated response system (warning → temporary restriction → ban)

### Consequences
- **Positive**: Community safety, scalable moderation, legal protection
- **Negative**: Content delay, moderation overhead
- **Mitigation**: Fast approval process, clear community guidelines

## ADR-007: Image Storage and Optimization

**Date**: 2025-01-19
**Status**: Accepted

### Context
Images are core to the app but need optimization for performance and cost.

### Decision
- Process all images on-device before upload
- Generate thumbnails for list views
- Compress images to max 5MB
- Use Supabase Storage with public buckets
- Implement cleanup for orphaned images

### Consequences
- **Positive**: Fast loading, controlled costs, good UX
- **Negative**: Processing time, device resource usage
- **Mitigation**: Background processing, clear progress indicators

## ADR-008: Authentication and User Management

**Date**: 2025-01-19
**Status**: Accepted

### Context
Need simple authentication with social login options and user profiles.

### Decision
- Use Supabase Auth with email/password and social providers
- Automatic profile creation via database triggers
- Optional profile setup with username and bio
- Support for anonymous browsing (view-only)

### Consequences
- **Positive**: Simple onboarding, flexible user engagement, privacy options
- **Negative**: Some features require authentication
- **Mitigation**: Clear value proposition for account creation

## ADR-009: Schema Alignment with Requirements

**Date**: 2025-01-19
**Status**: Accepted

### Context
Initial implementation used different table/column names than the original specification. Need to align exactly with requirements.

### Decision
- Migrate from `profiles/items` to `users/submissions` naming
- Update enum values to match specification (`CC_BY_NC` vs `cc_by_nc`)
- Implement exact RLS policy: `safety_flags.hidden != true`
- Add missing tables: `lists`, `tags`, `submission_tags`
- Seed specified tags: shiny, tiny, mystery, colorful
- Create comprehensive migration documentation

### Consequences
- **Positive**: 100% compliance with requirements, OCR support, flexible tagging
- **Negative**: Required model updates, service layer changes
- **Mitigation**: Updated Flutter models and maintained API compatibility

## Future Considerations

### Potential ADRs for Future Iterations
- **Offline Support**: Local database sync strategy
- **Real-time Features**: WebSocket vs polling for live updates
- **Push Notifications**: Timing and relevance strategies
- **Performance Monitoring**: Crash reporting and analytics
- **Internationalization**: Multi-language support approach
- **Accessibility**: Screen reader and motor impairment support
- **API Rate Limiting**: User experience during high traffic
- **Data Export**: User data portability and GDPR compliance

### Technical Debt to Monitor
- Image processing performance on older devices
- Database query optimization as data grows
- Search relevance tuning
- Geohash neighbor calculation accuracy
- ML Kit model updates and compatibility

This document will be updated as new architectural decisions are made during development.
