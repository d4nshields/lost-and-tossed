-- ============================================================
-- Lost and Tossed - Full Database Backup
-- Supabase Project: itosryiospovqdcrnjxr (lostandtossed)
-- Backup date: 2026-04-01
-- ============================================================

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================
-- CUSTOM ENUM TYPES
-- ============================================================
CREATE TYPE category AS ENUM ('lost', 'tossed', 'posted', 'marked', 'curious', 'traces');
CREATE TYPE license_type AS ENUM ('CC_BY_NC', 'CC0');
CREATE TYPE trace_surface AS ENUM ('soil', 'snow', 'pavement', 'glass', 'metal', 'wood', 'grass', 'other');
CREATE TYPE trace_freshness AS ENUM ('minutes', 'hours', 'days');
CREATE TYPE trace_permanence AS ENUM ('ephemeral', 'seasonal', 'semi_permanent');

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE users (
    id uuid NOT NULL,
    handle text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    email text,
    avatar_url text,
    bio text,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_handle_key UNIQUE (handle)
);

CREATE TABLE submissions (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    category category NOT NULL,
    caption text,
    tags text[],
    license license_type NOT NULL DEFAULT 'CC_BY_NC'::license_type,
    disposed boolean DEFAULT false,
    geohash5 text NOT NULL,
    lat double precision,
    lon double precision,
    found_at timestamp with time zone DEFAULT now(),
    urls jsonb NOT NULL,
    safety_flags jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT submissions_pkey PRIMARY KEY (id)
);

CREATE TABLE tags (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    CONSTRAINT tags_pkey PRIMARY KEY (id),
    CONSTRAINT tags_name_key UNIQUE (name)
);

CREATE TABLE submission_tags (
    submission_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    CONSTRAINT submission_tags_pkey PRIMARY KEY (submission_id, tag_id)
);

CREATE TABLE traces (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    submission_id uuid NOT NULL,
    surface trace_surface NOT NULL,
    freshness trace_freshness,
    direction_deg double precision,
    permanence trace_permanence,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT traces_pkey PRIMARY KEY (id),
    CONSTRAINT traces_submission_id_key UNIQUE (submission_id)
);

CREATE TABLE lists (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    submission_id uuid NOT NULL,
    ocr_text text,
    corrected_text text,
    word_count integer,
    CONSTRAINT lists_pkey PRIMARY KEY (id)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_submissions_user_id ON submissions USING btree (user_id);
CREATE INDEX idx_submissions_category ON submissions USING btree (category);
CREATE INDEX idx_submissions_found_at ON submissions USING btree (found_at DESC);
CREATE INDEX idx_submissions_geohash5 ON submissions USING btree (geohash5);
CREATE INDEX idx_submissions_safety_flags ON submissions USING gin (safety_flags);
CREATE INDEX idx_lists_submission_id ON lists USING btree (submission_id);
CREATE INDEX idx_submission_tags_submission_id ON submission_tags USING btree (submission_id);
CREATE INDEX idx_submission_tags_tag_id ON submission_tags USING btree (tag_id);
CREATE INDEX idx_tags_name ON tags USING btree (name);
CREATE INDEX idx_traces_submission_id ON traces USING btree (submission_id);

-- ============================================================
-- FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.generate_unique_handle()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    base_handle TEXT;
    final_handle TEXT;
    counter INT := 0;
    random_suffix TEXT;
BEGIN
    random_suffix := substr(md5(random()::text), 1, 6);
    base_handle := 'explorer_' || random_suffix;
    final_handle := base_handle;

    WHILE EXISTS (SELECT 1 FROM public.users WHERE handle = final_handle) LOOP
        counter := counter + 1;
        final_handle := base_handle || '_' || counter::text;
        IF counter > 999 THEN
            final_handle := 'user_' || floor(extract(epoch from now()))::text;
            EXIT;
        END IF;
    END LOOP;

    IF char_length(final_handle) > 20 THEN
        final_handle := substr(final_handle, 1, 20);
    END IF;

    RETURN final_handle;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'user_' || floor(extract(epoch from now()))::text;
END;
$function$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    INSERT INTO public.users (
        id, handle, email, avatar_url, created_at
    )
    VALUES (
        NEW.id,
        COALESCE(
            regexp_replace(split_part(NEW.email, '@', 1), '[^a-zA-Z0-9]', '_', 'g') || '_' || substr(md5(random()::text), 1, 4),
            'explorer_' || substr(md5(random()::text), 1, 6)
        ),
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'avatar_url',
            NEW.raw_user_meta_data->>'picture',
            NEW.raw_user_meta_data->>'photoUrl'
        ),
        COALESCE(NEW.created_at, NOW())
    )
    ON CONFLICT (id) DO UPDATE
    SET
        email = EXCLUDED.email,
        avatar_url = COALESCE(users.avatar_url, EXCLUDED.avatar_url);

    RETURN NEW;
EXCEPTION
    WHEN unique_violation THEN
        INSERT INTO public.users (
            id, handle, email, avatar_url, created_at
        )
        VALUES (
            NEW.id,
            'user_' || substr(NEW.id::text, 1, 8),
            NEW.email,
            NEW.raw_user_meta_data->>'avatar_url',
            NOW()
        )
        ON CONFLICT (id) DO UPDATE
        SET
            email = EXCLUDED.email,
            avatar_url = COALESCE(users.avatar_url, EXCLUDED.avatar_url);
        RETURN NEW;
    WHEN OTHERS THEN
        RAISE WARNING 'Error creating user profile: %', SQLERRM;
        RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.create_user_profile(user_id uuid DEFAULT NULL::uuid, user_email text DEFAULT NULL::text, user_avatar text DEFAULT NULL::text)
 RETURNS users
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_user_id UUID;
    v_email TEXT;
    v_avatar TEXT;
    v_handle TEXT;
    v_result public.users;
BEGIN
    v_user_id := COALESCE(user_id, auth.uid());
    v_email := COALESCE(user_email, auth.jwt()->>'email');
    v_avatar := COALESCE(user_avatar, auth.jwt()->'user_metadata'->>'avatar_url');

    v_handle := 'explorer_' || substr(md5(random()::text || v_user_id::text), 1, 6);

    WHILE EXISTS (SELECT 1 FROM public.users WHERE handle = v_handle) LOOP
        v_handle := 'explorer_' || substr(md5(random()::text || now()::text), 1, 6);
    END LOOP;

    INSERT INTO public.users (id, handle, email, avatar_url, created_at)
    VALUES (v_user_id, v_handle, v_email, v_avatar, NOW())
    ON CONFLICT (id) DO UPDATE
    SET
        email = COALESCE(EXCLUDED.email, users.email),
        avatar_url = COALESCE(EXCLUDED.avatar_url, users.avatar_url)
    RETURNING * INTO v_result;

    RETURN v_result;
END;
$function$;

-- ============================================================
-- TRIGGERS
-- ============================================================
CREATE TRIGGER update_traces_updated_at
    BEFORE UPDATE ON public.traces
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Note: The auth trigger (handle_new_user) is on auth.users, which is a Supabase-managed table.
-- To restore it: CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- VIEW: trace_details
-- ============================================================
CREATE OR REPLACE VIEW trace_details AS
SELECT s.id AS submission_id,
    s.user_id,
    s.category,
    s.caption,
    s.tags,
    s.license,
    s.disposed,
    s.geohash5,
    s.lat,
    s.lon,
    s.found_at,
    s.urls,
    s.safety_flags,
    s.created_at AS submission_created_at,
    t.id AS trace_id,
    t.surface,
    t.freshness,
    t.direction_deg,
    t.permanence,
    t.notes AS trace_notes,
    t.created_at AS trace_created_at,
    t.updated_at AS trace_updated_at
FROM submissions s
JOIN traces t ON s.id = t.submission_id
WHERE s.category = 'traces'::category;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE submission_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE traces ENABLE ROW LEVEL SECURITY;
ALTER TABLE lists ENABLE ROW LEVEL SECURITY;

-- users policies
CREATE POLICY "Users can view all profiles" ON users FOR SELECT TO public USING (true);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE TO public USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "Service role can do anything" ON users TO service_role USING (true) WITH CHECK (true);

-- submissions policies
CREATE POLICY "Users can view all submissions" ON submissions FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Users can create their own submissions" ON submissions FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own submissions" ON submissions FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own submissions" ON submissions FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "submissions_read_policy" ON submissions FOR SELECT TO public USING (COALESCE(((safety_flags ->> 'hidden'::text))::boolean, false) <> true);
CREATE POLICY "submissions_write_policy" ON submissions FOR INSERT TO public WITH CHECK (auth.uid() = user_id);
CREATE POLICY "submissions_update_policy" ON submissions FOR UPDATE TO public USING (auth.uid() = user_id);
CREATE POLICY "submissions_delete_policy" ON submissions FOR DELETE TO public USING (auth.uid() = user_id);

-- tags policies
CREATE POLICY "tags_read_policy" ON tags FOR SELECT TO public USING (true);
CREATE POLICY "tags_write_policy" ON tags FOR INSERT TO public WITH CHECK (auth.uid() IS NOT NULL);

-- submission_tags policies
CREATE POLICY "submission_tags_read_policy" ON submission_tags FOR SELECT TO public USING (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = submission_tags.submission_id AND COALESCE(((submissions.safety_flags ->> 'hidden'::text))::boolean, false) <> true));
CREATE POLICY "submission_tags_write_policy" ON submission_tags FOR INSERT TO public WITH CHECK (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = submission_tags.submission_id AND submissions.user_id = auth.uid()));
CREATE POLICY "submission_tags_delete_policy" ON submission_tags FOR DELETE TO public USING (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = submission_tags.submission_id AND submissions.user_id = auth.uid()));

-- traces policies
CREATE POLICY "Users can view all traces" ON traces FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Users can create traces for their submissions" ON traces FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = traces.submission_id AND submissions.user_id = auth.uid()));
CREATE POLICY "traces_select_policy" ON traces FOR SELECT TO public USING (EXISTS (SELECT 1 FROM submissions s WHERE s.id = traces.submission_id));
CREATE POLICY "traces_insert_policy" ON traces FOR INSERT TO public WITH CHECK (EXISTS (SELECT 1 FROM submissions s WHERE s.id = traces.submission_id AND s.user_id = auth.uid()));
CREATE POLICY "traces_update_policy" ON traces FOR UPDATE TO public USING (EXISTS (SELECT 1 FROM submissions s WHERE s.id = traces.submission_id AND s.user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM submissions s WHERE s.id = traces.submission_id AND s.user_id = auth.uid()));
CREATE POLICY "traces_delete_policy" ON traces FOR DELETE TO public USING (EXISTS (SELECT 1 FROM submissions s WHERE s.id = traces.submission_id AND s.user_id = auth.uid()));

-- lists policies
CREATE POLICY "lists_read_policy" ON lists FOR SELECT TO public USING (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = lists.submission_id AND COALESCE(((submissions.safety_flags ->> 'hidden'::text))::boolean, false) <> true));
CREATE POLICY "lists_write_policy" ON lists FOR INSERT TO public WITH CHECK (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = lists.submission_id AND submissions.user_id = auth.uid()));
CREATE POLICY "lists_update_policy" ON lists FOR UPDATE TO public USING (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = lists.submission_id AND submissions.user_id = auth.uid()));
CREATE POLICY "lists_delete_policy" ON lists FOR DELETE TO public USING (EXISTS (SELECT 1 FROM submissions WHERE submissions.id = lists.submission_id AND submissions.user_id = auth.uid()));

-- ============================================================
-- STORAGE BUCKETS (recreate in Supabase dashboard or via API)
-- ============================================================
-- Bucket: item-images (public, 5MB limit, image/jpeg,image/jpg,image/png,image/gif,image/webp)
-- Bucket: profile-avatars (public, 5MB limit, image/jpeg,image/jpg,image/png,image/gif,image/webp)

-- Storage policies (on storage.objects):
-- "Give all users access to view" FOR SELECT TO anon, authenticated USING (true)
-- "Give users access to upload" FOR INSERT TO authenticated WITH CHECK (auth.role() = 'authenticated')
-- "Give users access to update their own files" FOR UPDATE TO authenticated USING (auth.uid() = owner)
-- "Give users access to delete their own files" FOR DELETE TO authenticated USING (auth.uid() = owner)

-- ============================================================
-- DATA: users
-- ============================================================
INSERT INTO users (id, handle, created_at, email, avatar_url, bio) VALUES
('00823c2c-a610-4985-ada3-41f6ebde8329', 'd4nshields_095a', '2025-08-20 03:12:35.471269+00', 'd4nshields@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKlOMrujkLXxl_akvb_umpHJpuPtRzs8m6xWZ-BkSTTvHvdpwJR=s96-c', NULL),
('80eacc60-cd71-49db-99a5-4296f35d32ca', 'explorer_b07806', '2025-08-21 03:19:51.817045+00', 'dexterbarker.59715@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocIvF_YeiVdssMWhZRUz4EwEoN9lOgm7dVKBL1fgsnUBB42XAw=s96-c', NULL),
('0417bcf2-af34-4785-b2ac-9beaa75d6fa3', 'explorer_4efaaa', '2025-08-21 03:20:50.208969+00', 'larryguerrero.69522@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocJqADCW0rDI20XASl7PyPD3An_-HTxWIrL_tOuhHrsyFNBR8w=s96-c', NULL),
('bc993627-2ba2-4f27-ae4d-a4ba0cd7fede', 'explorer_af81bf', '2025-08-22 13:30:39.762962+00', 'doloresharrington.67496@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKe_IzdvFG41u-vwaGyncDmrWCqwNiOCJmnbZ6iM6UlpYzRYQ=s96-c', NULL),
('82dfd6ec-26c3-43a3-9a9a-52d86b41c45c', 'jimmassey_00702_d8d0', '2025-09-15 23:54:58.371604+00', 'jimmassey.00702@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKj40H0gOSWXPGutaKJztqBlqfo-X7m4XlwcQsNCMA_MCV5uw=s96-c', NULL),
('3bcb5947-adfb-4bf4-b992-8ff19291b7e4', 'chasahern_21469_cc0f', '2025-09-15 23:57:32.042494+00', 'chasahern.21469@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocI2p33FLV1aCQznzA3ENULPs4gOFdrPZXz0zQU9KfgghG1u_g=s96-c', NULL),
('205eafaf-5423-4b72-89ef-9a7262bd36cb', 'explorer_ec3161', '2025-09-16 01:52:13.237036+00', 'ednaperkins.25102@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocISLX8ByV7Khh8McRy1ZZpq6V9RczG-nB9HQoVJ11Kp_EEHcw=s96-c', NULL),
('b09549d9-4bd3-475b-a0ce-402e4176b689', 'explorer_3b0113', '2025-09-16 01:52:52.615769+00', 'jeffreeves.77178@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocLMTuRtqkOMKt09GWr-FjzYjS3CJ2K-7ArLCNaX4rloxlxPLA=s96-c', NULL),
('b493f8b6-4c20-4652-8f64-9857a8df6e4b', 'explorer_242abc', '2025-09-16 01:53:37.938607+00', 'corneliushicks.51363@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocK6IzuckOdKyUFAzU-m6a3OfSTQJNnfZNArZC-Xp_0SwSiB0A=s96-c', NULL),
('91cc4481-6df8-4657-8bff-d8fc9bb90591', 'explorer_cfeb69', '2025-09-16 03:12:36.806254+00', 'yolandagregory.65076@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocIUxK4oPAyrrqsg82Qe0TdPc_RHKfqKUJV3fKNLb-nFb906Zg=s96-c', NULL),
('bade1144-e792-4a47-9022-31110c59ea17', 'joshbanks_73283_acd3', '2025-09-16 03:15:34.837046+00', 'joshbanks.73283@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocLFEwtQ4fXNfOCrSZcBgY4urdLX-TgZH-9EwFGVNEjxLZzZqQ=s96-c', NULL),
('80ce00a3-46a7-413f-bf38-6e883887218d', 'explorer_7c1873', '2025-09-16 03:16:47.745937+00', 'freddiewoods.95848@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocL62z3eKa06N64knctms0Rzt6aV0DVJl-y2GiD7Sp2-mob7IQ=s96-c', NULL),
('82d590c1-f33d-4605-92a6-70615c25b8cb', 'explorer_2a2c91', '2025-09-16 13:43:33.527693+00', 'kimberlywells.83193@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKLel8jRtSQq2_MGOOY9qbKZZ_TaGfaU5uuNGyjjpRmZgEGdw=s96-c', NULL),
('9a7d52dd-beca-45b1-b194-695861d37b9b', 'explorer_f9e119', '2025-09-16 13:48:02.702479+00', 'rooseveltlawrence.10643@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKuopRuKvoOwUE1zQ_OQrlg6xJvnhbhGbaN47t6EfWQVG6Rlg=s96-c', NULL),
('80c894e5-203f-4fea-9a98-48456fc93fe7', 'explorer_4e4f4e', '2025-09-16 20:43:07.94706+00', 'nicolaswheeler.37849@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocIYNq-Y4fU7ujwSzKCGkvtH7bV9tkNjnbK73op4JLPPOP0NPA=s96-c', NULL),
('4c7d3276-5f4f-4cda-95ce-f53c673be60e', 'luismoody_86978_ecd8', '2025-09-16 20:44:34.417795+00', 'luismoody.86978@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocLAdIFk-GiPk053eam9LFzH1ZT0mB0FzUTvOKPDnBq3nmy40A=s96-c', NULL),
('d2493a23-4cbd-427d-a20f-78ffcd0aa4fd', 'explorer_f7b7e6', '2025-09-16 20:45:21.304239+00', 'maryannwolfe.25455@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKHU7LRfp1vUNdsZHyN0l5MzWwAUbregt_YZi_TC6kJXdUqMA=s96-c', NULL),
('251bb35d-4ef8-4aa0-b804-62cf232e1c78', 'olaevosiqueira_92cd', '2025-09-18 03:55:45.823355+00', 'olaevosiqueira@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocJm_w9WDmVUpt3GA_3X3SsEnlFu8eTcwkp_Cez1h6nO53w0aQ=s96-c', NULL),
('d99104b1-aad3-4590-905e-17d8ffc5c0d4', 'shawnagan932_4f74', '2025-09-19 01:49:41.394809+00', 'shawnagan932@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocL2FzllsO_0H25yCzF0cLqlUNcFSvfRM2ZIbcJIM4MPgS3pzi0=s96-c', NULL),
('95fcf40c-2bd9-45e5-a966-3c2e475e95f5', 'jenniferbeads_cc7e', '2025-12-10 12:04:28.758262+00', 'jenniferbeads@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKPKvm7O4ejMpJihTslegojQ-tThBq1ZZrhIx-9nUA-M_BuxZRu=s96-c', NULL);

-- ============================================================
-- DATA: tags
-- ============================================================
INSERT INTO tags (id, name) VALUES
('767adb54-bfe9-404b-9272-3d0952eee08f', 'shiny'),
('acac4d41-617a-4e94-ac49-1e1b4df433ba', 'tiny'),
('7586b701-cc22-47fc-bdd5-f90c6bac3a08', 'mystery'),
('596384c4-5409-457a-be98-39b5de12da3b', 'colorful');

-- ============================================================
-- DATA: submissions
-- ============================================================
INSERT INTO submissions (id, user_id, category, caption, tags, license, disposed, geohash5, lat, lon, found_at, urls, safety_flags, created_at) VALUES
('f00a956a-841c-4bef-bb3d-73e1fb365264', '00823c2c-a610-4985-ada3-41f6ebde8329', 'tossed', '', ARRAY['forgotten'], 'CC_BY_NC', false, 'dpzce', 43.8579493, -78.9469535, '2025-09-16 10:04:39.467917+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/55555032-227b-4c7e-be6d-6351fbe6ee8b.jpg"}', '{}', '2025-09-16 14:04:38.48847+00'),
('cbf3ab19-86ba-44a4-b559-20f09526533e', '00823c2c-a610-4985-ada3-41f6ebde8329', 'tossed', '', ARRAY[]::text[], 'CC_BY_NC', false, 'dpzce', 43.8579502, -78.9469667, '2025-09-16 16:40:18.735399+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/fdb8cd80-294e-4d7a-975f-252fce6dab86.jpg"}', '{}', '2025-09-16 20:40:16.982779+00'),
('b0e2c694-65cb-495b-8c89-2de988e8e390', '00823c2c-a610-4985-ada3-41f6ebde8329', 'posted', '', ARRAY[]::text[], 'CC_BY_NC', true, 'dpzce', 43.8579571, -78.9469594, '2025-09-16 16:41:59.693526+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/a92cef16-b93a-4537-a5c8-b5c499f6715d.jpg"}', '{}', '2025-09-16 20:41:58.186133+00'),
('6bdb0b77-dd12-4513-a853-cc6816888264', '00823c2c-a610-4985-ada3-41f6ebde8329', 'curious', '', ARRAY[]::text[], 'CC_BY_NC', false, 'dpzce', 43.8579506, -78.9469491, '2025-09-16 22:45:28.395726+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/cf98d90e-d684-4644-833d-632395b59b78.jpg"}', '{}', '2025-09-17 02:45:26.35962+00'),
('f9269265-6eb9-430b-89de-a3bd8f901d1f', '00823c2c-a610-4985-ada3-41f6ebde8329', 'tossed', 'Scarborough winter sunrise', ARRAY['mystery'], 'CC_BY_NC', false, 'dpzce', 43.8579681, -78.9469216, '2025-12-08 12:54:45.385294+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/fb919881-a675-4c49-bcff-44fef3aa0abd.jpg"}', '{}', '2025-12-08 17:54:43.737201+00'),
('a841b60a-ae1f-4ec9-a5a8-f3a7e749a018', '00823c2c-a610-4985-ada3-41f6ebde8329', 'tossed', '', ARRAY['mystery'], 'CC_BY_NC', false, 'dpzce', 43.8579536, -78.9469473, '2025-12-09 10:56:49.512873+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/08ab0f73-af5d-40e3-800a-74e0523b524b.jpg"}', '{}', '2025-12-09 15:56:48.560369+00'),
('8f01417b-4aa2-4411-aa5a-1442d8af0567', '00823c2c-a610-4985-ada3-41f6ebde8329', 'traces', '', ARRAY[]::text[], 'CC_BY_NC', false, 'dpzce', 43.8579565, -78.9468129, '2025-12-15 08:31:28.989125+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/9045a325-ebe5-4977-a759-e38e87c33464.jpg"}', '{}', '2025-12-15 13:31:28.486683+00'),
('9a00b6af-5272-4eae-88f3-8188a5200874', '95fcf40c-2bd9-45e5-a966-3c2e475e95f5', 'traces', 'a long overdue to do pile. ', ARRAY['vintage','forgotten'], 'CC_BY_NC', false, 'dpz9h', 43.777948, -79.2356869, '2025-12-17 13:00:03.933321+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/95fcf40c-2bd9-45e5-a966-3c2e475e95f5/e8b8cdc1-4cdb-4ee4-961c-9e6afab8b4e4.jpg"}', '{}', '2025-12-17 18:00:03.592963+00'),
('28453e18-a475-4b52-b692-e2a6fef98d60', '00823c2c-a610-4985-ada3-41f6ebde8329', 'curious', 'A story, half told ', ARRAY[]::text[], 'CC_BY_NC', true, 'dpzce', 43.8579663, -78.9469459, '2026-02-01 12:25:08.468804+00', '{"original":"https://itosryiospovqdcrnjxr.supabase.co/storage/v1/object/public/item-images/00823c2c-a610-4985-ada3-41f6ebde8329/676977c1-eb0a-49cf-bcea-6026a6e128ba.jpg"}', '{}', '2026-02-01 17:25:06.312514+00');

-- ============================================================
-- DATA: submission_tags (empty)
-- ============================================================
-- No rows

-- ============================================================
-- DATA: traces
-- ============================================================
INSERT INTO traces (id, submission_id, surface, freshness, direction_deg, permanence, notes, created_at, updated_at) VALUES
('e5173489-9133-489d-92f1-b7758815aec7', '8f01417b-4aa2-4411-aa5a-1442d8af0567', 'snow', 'days', NULL, 'ephemeral', NULL, '2025-12-15 13:31:28.616823+00', '2025-12-15 13:31:28.616823+00'),
('4543f973-97b3-4572-82a8-53ffea9c1e88', '9a00b6af-5272-4eae-88f3-8188a5200874', 'other', NULL, NULL, 'semi_permanent', NULL, '2025-12-17 18:00:04.339489+00', '2025-12-17 18:00:04.339489+00');

-- ============================================================
-- DATA: lists (empty)
-- ============================================================
-- No rows

-- ============================================================
-- MIGRATIONS HISTORY
-- ============================================================
-- 20250811030623 - 001_initial_schema
-- 20250811030641 - 002_rls_policies
-- 20250811032907 - 003_align_with_requirements
-- 20250812012021 - add_traces_enums_and_category
-- 20250812012039 - add_traces_table_and_policies
-- 20250819114227 - 006_auth_and_handle_generation
-- 20250820030724 - 007_fix_user_creation_trigger
-- 20250820030742 - 008_improve_handle_generation
-- 20250820030825 - 009_fix_handle_format
-- 20250820030930 - 010_robust_user_creation
-- 20250820030953 - 011_fix_rls_policies
-- 20250820031011 - 012_create_user_profile_function
-- 20250916015253 - enable_rls_and_policies_for_submissions
-- 20250916015320 - create_storage_bucket_policies

-- ============================================================
-- STORAGE OBJECTS MANIFEST (see backup/images/ for downloaded files)
-- ============================================================
-- item-images/00823c2c.../08ab0f73-af5d-40e3-800a-74e0523b524b.jpg (466 KB)
-- item-images/00823c2c.../55555032-227b-4c7e-be6d-6351fbe6ee8b.jpg (263 KB)
-- item-images/00823c2c.../676977c1-eb0a-49cf-bcea-6026a6e128ba.jpg (180 KB)
-- item-images/00823c2c.../9045a325-ebe5-4977-a759-e38e87c33464.jpg (414 KB)
-- item-images/00823c2c.../a92cef16-b93a-4537-a5c8-b5c499f6715d.jpg (607 KB)
-- item-images/00823c2c.../cf98d90e-d684-4644-833d-632395b59b78.jpg (282 KB)
-- item-images/00823c2c.../fb919881-a675-4c49-bcff-44fef3aa0abd.jpg (466 KB)
-- item-images/00823c2c.../fdb8cd80-294e-4d7a-975f-252fce6dab86.jpg (337 KB)
-- item-images/95fcf40c.../e8b8cdc1-4cdb-4ee4-961c-9e6afab8b4e4.jpg (551 KB)
