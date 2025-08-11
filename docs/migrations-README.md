# Lost & Tossed Database Migrations

This directory contains the database schema and migration files for the Lost & Tossed application using Supabase.

## Overview

Lost & Tossed uses a PostgreSQL database hosted on Supabase with Row Level Security (RLS) policies to ensure data privacy and security.

## Schema Structure

### Core Tables

1. **users** - User profiles linked to Supabase auth
   - `id` (UUID, PK, refs auth.users)
   - `handle` (TEXT, unique)
   - `created_at` (TIMESTAMPTZ)

2. **submissions** - Main content table for found objects
   - `id` (UUID, PK)
   - `user_id` (UUID, FK to users)
   - `category` (ENUM: lost, tossed, posted, marked, curious)
   - `caption` (TEXT)
   - `tags` (TEXT[])
   - `license` (ENUM: CC_BY_NC, CC0, default CC_BY_NC)
   - `disposed` (BOOLEAN, default false)
   - `geohash5` (TEXT, required - 5-char geohash for privacy)
   - `lat`, `lon` (DOUBLE PRECISION, optional exact coordinates)
   - `found_at` (TIMESTAMPTZ, default now())
   - `urls` (JSONB, required - image URLs and metadata)
   - `safety_flags` (JSONB, default {})
   - `created_at` (TIMESTAMPTZ, default now())

3. **lists** - OCR text processing for found lists/documents
   - `id` (UUID, PK)
   - `submission_id` (UUID, FK to submissions)
   - `ocr_text` (TEXT)
   - `corrected_text` (TEXT)
   - `word_count` (INTEGER, generated column)

4. **tags** - Predefined and user-created tags
   - `id` (UUID, PK)
   - `name` (TEXT, unique)

5. **submission_tags** - Many-to-many relation between submissions and tags
   - `submission_id` (UUID, FK to submissions)
   - `tag_id` (UUID, FK to tags)
   - Primary key on (submission_id, tag_id)

### Enums

- **category**: 'lost', 'tossed', 'posted', 'marked', 'curious'
- **license_type**: 'CC_BY_NC', 'CC0'

## Row Level Security (RLS) Policies

### Submissions Table
- **Read Policy**: Allow if `safety_flags.hidden != true`
- **Write/Update/Delete**: Allow if `auth.uid() = user_id`

### Other Tables
- **users**: Users can read all profiles, but only modify their own
- **lists**: Access controlled through submission ownership
- **tags**: Public read, authenticated write
- **submission_tags**: Access controlled through submission ownership

## Running Migrations

### Using Supabase CLI

1. **Install Supabase CLI**:
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase**:
   ```bash
   supabase login
   ```

3. **Link to your project**:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

4. **Apply migrations**:
   ```bash
   supabase db push
   ```

### Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste migration content
4. Execute the SQL

### Manual Migration Order

If running migrations manually, execute in this order:

1. `001_initial_schema.sql` - Basic tables and initial setup
2. `002_rls_policies.sql` - Row Level Security policies
3. `003_align_with_requirements.sql` - Updated schema matching requirements

## Migration Files

### 001_initial_schema.sql
- Creates extensions (uuid-ossp, postgis)
- Creates enum types
- Creates core tables with constraints
- Creates indexes for performance
- Sets up triggers for updated_at columns

### 002_rls_policies.sql
- Enables RLS on all tables
- Creates security policies
- Sets up auth triggers

### 003_align_with_requirements.sql
- Aligns schema with exact requirements
- Updates table and column names
- Corrects enum values
- Seeds initial tag data

## Seeded Data

The database includes these pre-seeded tags:
- `shiny`
- `tiny`
- `mystery`
- `colorful`

## Important Notes

### Privacy Design
- **Geohash Storage**: Location data is stored as 5-character geohash (~152m precision) for privacy
- **Optional Exact Coordinates**: Precise lat/lon stored separately with user consent
- **Safety Flags**: Content can be hidden via `safety_flags.hidden = true`

### Image Storage
- Images are stored in Supabase Storage
- URLs stored in `submissions.urls` JSONB field
- Structure: `{"original": "url", "thumbnail": "url", "processed": "url"}`

### Performance Considerations
- Indexes on commonly queried fields (user_id, category, geohash5, found_at)
- GIN index on safety_flags JSONB for efficient querying
- Generated word_count column for list analysis

## Development vs Production

### Development
```sql
-- Enable more permissive policies for testing
-- (Add development-specific policies here if needed)
```

### Production
```sql
-- Ensure all RLS policies are properly configured
-- Monitor safety_flags usage
-- Regular cleanup of soft-deleted content
```

## Troubleshooting

### Common Issues

1. **RLS Policy Errors**: Ensure auth.uid() is not null when testing policies
2. **Geohash Validation**: Must be exactly 5 characters
3. **JSONB Structure**: Ensure urls field follows expected structure
4. **Foreign Key Violations**: Check user creation via auth trigger

### Testing Policies

```sql
-- Test as authenticated user
SELECT set_config('request.jwt.claims', '{"sub": "user-uuid-here"}', true);

-- Test read access
SELECT * FROM submissions;

-- Test write access
INSERT INTO submissions (user_id, category, caption, geohash5, urls) 
VALUES (auth.uid(), 'lost', 'Test item', 'abcde', '{"original": "test.jpg"}');
```

## Migration Verification

After running migrations, verify:

1. **Tables exist**: Check all 5 tables are created
2. **RLS enabled**: All tables should have RLS enabled
3. **Policies active**: Test CRUD operations with different users
4. **Seeded data**: Verify 4 initial tags exist
5. **Constraints**: Test data validation rules

```sql
-- Verification queries
\dt public.*;                    -- List tables
SELECT * FROM tags;              -- Check seeded tags
SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';  -- Check RLS status
```
