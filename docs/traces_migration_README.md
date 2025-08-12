# Traces Migration for Lost & Tossed

## Overview
This migration adds comprehensive support for the "traces" category in the Lost & Tossed app. Traces represent ephemeral marks of human presence like footprints, tire tracks, scuffs, flattened grass, sticker/poster shadows, and chalk lines.

## Schema Changes

### 1. New Enum Types
- **`trace_surface`**: `'soil','snow','pavement','glass','metal','wood','grass','other'`
- **`trace_freshness`**: `'minutes','hours','days'` 
- **`trace_permanence`**: `'ephemeral','seasonal','semi_permanent'`

### 2. Extended Category Enum
- Added `'traces'` value to existing `category` enum
- Now supports: `'lost','tossed','posted','marked','curious','traces'`

### 3. New `traces` Table
```sql
CREATE TABLE traces (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id uuid UNIQUE NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
    surface trace_surface NOT NULL,
    freshness trace_freshness,
    direction_deg double precision,  -- nullable, 0-359 degrees
    permanence trace_permanence,
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
```

### 4. Indexes
- `idx_traces_submission_id` on `traces(submission_id)` for performance

### 5. Row Level Security (RLS)
The `traces` table inherits security from the parent `submissions` table:
- **SELECT**: Users can only see traces for submissions they can view
- **INSERT**: Users can only create traces for their own submissions
- **UPDATE**: Users can only modify traces for their own submissions  
- **DELETE**: Users can only delete traces for their own submissions

### 6. `trace_details` View
A read-only view that joins `submissions` and `traces` tables for easy querying:
```sql
SELECT * FROM trace_details WHERE submission_id = ?;
```

## Migration Files
1. `add_traces_enums_and_category` - Creates new enums and extends category
2. `add_traces_table_and_policies` - Creates table, RLS policies, view, and triggers

## Usage Examples

### Creating a trace submission:
```sql
-- 1. Insert submission
INSERT INTO submissions (user_id, category, caption, geohash5, ...)
VALUES (auth.uid(), 'traces', 'Fresh footprints in snow', 'dr5rz', ...);

-- 2. Insert trace details
INSERT INTO traces (submission_id, surface, freshness, direction_deg, permanence, notes)
VALUES (?, 'snow', 'minutes', 45.0, 'ephemeral', 'Clear boot treads heading northeast');
```

### Querying trace details:
```sql
SELECT * FROM trace_details 
WHERE geohash5 LIKE 'dr5r%' 
AND surface = 'snow' 
AND freshness = 'minutes';
```

## Data Model Design Decisions

### 1. **1:1 Relationship**: `traces` has a unique foreign key to `submissions`
- Ensures each submission can have at most one trace record
- Maintains data integrity and prevents duplication
- Uses CASCADE delete for automatic cleanup

### 2. **Nullable Fields**: Most trace-specific fields are optional
- `freshness`, `direction_deg`, `permanence`, `notes` can be NULL
- Only `surface` is required as it's fundamental to trace identification
- Allows for partial data entry when some details are unknown

### 3. **Direction Storage**: Uses degrees (0-359) as `double precision`
- Standard geographic notation (0 = North, 90 = East, etc.)
- Nullable to handle traces without clear directional information
- Precise enough for detailed analysis while remaining human-readable

### 4. **RLS Inheritance**: Security policies reference parent submission
- Leverages existing `submissions` RLS policies
- Ensures consistent permissions across related data
- Simplifies security model maintenance

### 5. **View for Convenience**: `trace_details` provides denormalized access
- Reduces join complexity in application code
- Includes all submission fields plus trace-specific data
- Automatically filtered to only show trace category submissions

## Testing
The migration includes a basic test to verify schema creation and RLS policies are working correctly.

## Micro-copy Integration
The trace category fits perfectly with the app's observational tone:
- "Footsteps that whisper stories of a journey."
- "The ghost of a bicycle's passage."
- "Where someone paused, the earth remembers."
