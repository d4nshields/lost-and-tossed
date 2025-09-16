# Authentication Architecture

## Overview
Lost & Tossed uses Supabase Auth with Google Sign-In as the sole authentication provider. This decision simplifies the authentication flow while providing a secure and familiar sign-in experience for users.

## Key Decisions

### 1. Google Sign-In Only
**Decision**: Use Google Sign-In exclusively, no Apple Sign-In or email/password auth.

**Rationale**:
- Simplifies authentication implementation and maintenance
- Google accounts are ubiquitous on Android devices
- Reduces authentication-related support issues
- Avoids managing password resets and email verification

**Trade-offs**:
- Some users may prefer other authentication methods
- Future iOS release will need to add Apple Sign-In for App Store compliance

### 2. Automatic Handle Generation
**Decision**: Generate unique handles automatically on first login using a database trigger.

**Rationale**:
- Reduces friction during onboarding
- Ensures all users have unique identifiers immediately
- Handles follow pattern: `explorer_[random]` with numeric suffix if needed
- Users can change their handle later if desired

**Implementation**:
```sql
-- Database trigger creates user profile automatically
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 3. Session-Based Route Protection
**Decision**: Use SessionGuard component and router redirects for protecting authenticated routes.

**Rationale**:
- Declarative approach to route protection
- Centralized authentication logic in the router
- Automatic redirects based on auth state
- Clean separation of concerns

**Implementation**:
- Router watches `authUserProvider` stream
- Redirects to `/auth/login` when not authenticated
- Redirects to `/` when authenticated user accesses auth pages
- SessionGuard widget wraps protected components

### 4. Three-Tab Navigation
**Decision**: Bottom navigation with three tabs: Explore, Capture, and Notebook.

**Rationale**:
- **Explore**: Combines map and feed views for discovery
- **Capture**: Central action for contributing content
- **Notebook**: Personal collection and stats
- Follows Material Design 3 guidelines
- Optimal for thumb reach on mobile devices

### 5. Profile Data Structure
**Decision**: Separate `users` table with foreign key to `auth.users`.

**Schema**:
```sql
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    handle TEXT UNIQUE NOT NULL,
    email TEXT,
    avatar_url TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Rationale**:
- Keeps authentication separate from application data
- Allows for profile customization
- Enables public profiles while protecting auth data
- Supports future social features

## Auth Flow

1. **Initial Load**
   - App initializes Supabase client
   - Checks for existing session
   - Shows loading screen during auth check

2. **Sign In**
   - User taps "Continue with Google"
   - Google OAuth flow initiated
   - Supabase creates auth user
   - Database trigger creates user profile
   - User redirected to home (Explore tab)

3. **Session Management**
   - Auth state stored in Riverpod providers
   - Session persisted by Supabase
   - Auto-refresh of expired tokens
   - Sign out clears local and remote sessions

4. **Protected Routes**
   - Router checks auth state on navigation
   - Unauthenticated users redirected to login
   - Auth state changes trigger automatic navigation

## Security Considerations

1. **Row Level Security (RLS)**
   - All tables have RLS enabled
   - Users can view all profiles (public)
   - Users can only edit their own profile
   - Submissions require authentication

2. **Token Management**
   - Supabase handles token refresh automatically
   - Tokens stored securely by Supabase SDK
   - No custom token handling required

3. **Data Privacy**
   - Exact location data kept private (only geohash stored publicly)
   - Email addresses not publicly visible
   - User deletion support planned

## Testing Strategy

1. **Unit Tests**
   - Auth repository methods
   - Handle generation logic
   - Profile update validation

2. **Widget Tests**
   - Auth redirect behavior
   - Login screen UI
   - Navigation based on auth state

3. **Integration Tests**
   - Complete sign-in flow
   - New user bootstrap
   - Session persistence

## Future Considerations

1. **iOS Support**
   - Add Apple Sign-In for App Store compliance
   - Maintain Google Sign-In as option
   - Share same user profile structure

2. **Account Linking**
   - Allow users to link multiple auth providers
   - Prevent duplicate profiles
   - Maintain handle uniqueness

3. **Account Deletion**
   - Implement GDPR-compliant deletion
   - Archive contributions vs. hard delete
   - Provide data export option

## Dependencies

- `supabase_flutter: ^2.3.4` - Auth and database
- `google_sign_in: ^6.2.1` - Google OAuth
- `flutter_riverpod: ^2.4.5` - State management
- `go_router: ^12.1.1` - Navigation with guards
