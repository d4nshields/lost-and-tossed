# Lost and Tossed - Supabase Restoration Guide

**Project deleted:** 2026-04-01
**Original project ID:** itosryiospovqdcrnjxr
**Region:** us-east-1
**Organization:** Tinkerplex Labs (zyrnwkznqlipfawedbai)
**Postgres version:** 17.4
**Why deleted:** Unused second project costing $10/month on top of Pro plan

## What's in this backup

- `schema_and_data.sql` — Complete SQL dump: enums, tables, indexes, functions, triggers, views, RLS policies, storage config, and all row data
- `images/` — All 9 uploaded photos from the `item-images` storage bucket

## Restoration steps

### 1. Create a new Supabase project

- Go to https://supabase.com/dashboard or use the CLI/MCP
- Create a new project under the **Tinkerplex Labs** organization
- Choose region **us-east-1** (or wherever you prefer)
- Note the new project ID and database password

### 2. Enable the PostGIS extension

In the Supabase SQL Editor or via CLI:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

### 3. Run the schema and data restore

Open `schema_and_data.sql` in the Supabase SQL Editor (or connect via `psql`) and execute it. The file is self-contained and ordered correctly (types -> tables -> indexes -> functions -> triggers -> views -> RLS -> data).

If using psql:
```bash
psql "postgresql://postgres.[project-ref]:[password]@aws-0-us-east-1.pooler.supabase.com:6543/postgres" -f backup/schema_and_data.sql
```

### 4. Recreate the auth trigger

The `handle_new_user` function is included in the SQL dump, but the trigger on `auth.users` must be created separately (it's in the `auth` schema which requires elevated privileges):

```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

Run this in the Supabase SQL Editor (which has superuser access).

### 5. Create storage buckets

In the Supabase dashboard under Storage, create:

1. **item-images**
   - Public: Yes
   - File size limit: 5 MB
   - Allowed MIME types: image/jpeg, image/jpg, image/png, image/gif, image/webp

2. **profile-avatars**
   - Public: Yes
   - File size limit: 5 MB
   - Allowed MIME types: image/jpeg, image/jpg, image/png, image/gif, image/webp

### 6. Set storage RLS policies

In the SQL Editor:

```sql
-- Allow anyone to view files
CREATE POLICY "Give all users access to view"
  ON storage.objects FOR SELECT
  TO anon, authenticated
  USING (true);

-- Allow authenticated users to upload
CREATE POLICY "Give users access to upload"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

-- Allow users to update their own files
CREATE POLICY "Give users access to update their own files"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner);

-- Allow users to delete their own files
CREATE POLICY "Give users access to delete their own files"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (auth.uid() = owner);
```

### 7. Re-upload images

Upload the images from `backup/images/` to the `item-images` bucket, preserving the user-id/filename path structure. The mapping is:

| Local filename | Storage path |
|---|---|
| 08ab0f73-af5d-40e3-800a-74e0523b524b.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/08ab0f73-af5d-40e3-800a-74e0523b524b.jpg |
| 55555032-227b-4c7e-be6d-6351fbe6ee8b.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/55555032-227b-4c7e-be6d-6351fbe6ee8b.jpg |
| 676977c1-eb0a-49cf-bcea-6026a6e128ba.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/676977c1-eb0a-49cf-bcea-6026a6e128ba.jpg |
| 9045a325-ebe5-4977-a759-e38e87c33464.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/9045a325-ebe5-4977-a759-e38e87c33464.jpg |
| a92cef16-b93a-4537-a5c8-b5c499f6715d.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/a92cef16-b93a-4537-a5c8-b5c499f6715d.jpg |
| cf98d90e-d684-4644-833d-632395b59b78.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/cf98d90e-d684-4644-833d-632395b59b78.jpg |
| fb919881-a675-4c49-bcff-44fef3aa0abd.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/fb919881-a675-4c49-bcff-44fef3aa0abd.jpg |
| fdb8cd80-294e-4d7a-975f-252fce6dab86.jpg | 00823c2c-a610-4985-ada3-41f6ebde8329/fdb8cd80-294e-4d7a-975f-252fce6dab86.jpg |
| e8b8cdc1-4cdb-4ee4-961c-9e6afab8b4e4.jpg | 95fcf40c-2bd9-45e5-a966-3c2e475e95f5/e8b8cdc1-4cdb-4ee4-961c-9e6afab8b4e4.jpg |

### 8. Update the submission URLs

After uploading images, the `urls` column in `submissions` references the old project ID (`itosryiospovqdcrnjxr`). Update to the new project ref:

```sql
UPDATE submissions
SET urls = jsonb_set(
  urls,
  '{original}',
  to_jsonb(replace(urls->>'original', 'itosryiospovqdcrnjxr', 'NEW_PROJECT_REF'))
);
```

### 9. Configure auth providers

The original project used **Google OAuth** for sign-in. You'll need to:
- Set up Google OAuth credentials in the Supabase Auth settings
- Update the redirect URLs in your Google Cloud Console to point to the new project

### 10. Update app configuration

Update your Flutter app's Supabase config (URL + anon key) to point to the new project. The relevant files are typically:
- `lib/config/` or environment files with the Supabase URL and anon key

## Data summary at time of backup

- 20 users
- 9 submissions (4 tossed, 2 curious, 1 posted, 2 traces)
- 4 tags (shiny, tiny, mystery, colorful)
- 2 trace records
- 0 lists, 0 submission_tags
- 9 images (~3.4 MB)
