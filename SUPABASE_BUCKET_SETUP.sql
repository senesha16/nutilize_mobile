-- ===================================================================
-- Supabase Storage Bucket Setup for Report Images
-- ===================================================================
-- This script enables authenticated users to upload report images
-- to the 'assets' bucket in the 'issues/' folder.
--
-- Run this in your Supabase SQL Editor:
-- 1. Go to your Supabase project dashboard
-- 2. Click "SQL Editor" in the left sidebar
-- 3. Click "New Query"
-- 4. Paste the content below and execute
-- ===================================================================

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow public upload to assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow public update assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow public delete assets" ON storage.objects;

-- Important: this app does not use Supabase Auth login for uploads.
-- The client uploads as the anon/public role, so these policies must
-- allow the public role to write to the assets bucket.
CREATE POLICY "Allow public upload to assets"
  ON storage.objects
  FOR INSERT
  TO public
  WITH CHECK (
    bucket_id = 'assets'
  );

-- Allow public read from assets so web can display uploaded images
CREATE POLICY "Allow public read assets"
  ON storage.objects
  FOR SELECT
  TO public
  USING (
    bucket_id = 'assets'
  );

-- Optional maintenance policies for the same bucket
CREATE POLICY "Allow public update assets"
  ON storage.objects
  FOR UPDATE
  TO public
  USING (
    bucket_id = 'assets'
  )
  WITH CHECK (
    bucket_id = 'assets'
  );

CREATE POLICY "Allow public delete assets"
  ON storage.objects
  FOR DELETE
  TO public
  USING (
    bucket_id = 'assets'
  );

-- ===================================================================
-- ALTERNATIVE: If you prefer public read access for report images
-- (so they can be viewed without authentication), uncomment below:
-- ===================================================================

-- CREATE POLICY "Allow public read to assets"
--   ON storage.objects
--   FOR SELECT
--   USING (bucket_id = 'assets');

-- ===================================================================
-- Notes:
-- 1. Make sure your 'assets' bucket exists before running this
-- 2. This script now allows all authenticated users to upload/read/delete
-- 3. Test by uploading a report image and verifying the URL works
-- ===================================================================
