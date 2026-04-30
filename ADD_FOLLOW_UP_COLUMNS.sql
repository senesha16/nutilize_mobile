-- ============================================================================
-- ADD FOLLOW-UP COLUMNS TO RESERVATION_APPROVALS TABLE
-- ============================================================================
-- This adds follow-up tracking to the reservation_approvals table
-- No new tables needed - just adds columns to existing table
--
-- Columns added:
-- - follow_up_requested: boolean (default false)
-- - follow_up_requested_at: timestamp
-- - follow_up_requested_by: bigint (references users.user_id)
-- ============================================================================

-- Add follow-up columns to reservation_approvals table
ALTER TABLE public.reservation_approvals
ADD COLUMN follow_up_requested boolean NOT NULL DEFAULT false,
ADD COLUMN follow_up_requested_at timestamp without time zone,
ADD COLUMN follow_up_requested_by bigint;

-- Add foreign key constraint for follow_up_requested_by
ALTER TABLE public.reservation_approvals
ADD CONSTRAINT reservation_approvals_follow_up_requested_by_foreign
FOREIGN KEY (follow_up_requested_by) REFERENCES public.users(user_id);

-- ============================================================================
-- INSTRUCTIONS FOR DEPLOYMENT
-- ============================================================================
-- 1. Copy this entire SQL
-- 2. Open Supabase Dashboard → SQL Editor
-- 3. Create a NEW query
-- 4. Paste this entire SQL
-- 5. Click "Run"
-- 6. Verify the columns were added (check Table Editor)
--
-- VERIFICATION QUERY:
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'reservation_approvals'
-- AND column_name LIKE 'follow_up%'
-- ORDER BY ordinal_position;
-- ============================================================================

-- ============================================================================
-- WEB SYSTEM INTEGRATION
-- ============================================================================
-- Your web system can now query for follow-up requests:
--
-- SELECT ra.*, r.activity_name, u.full_name as requested_by_name, o.department_name
-- FROM reservation_approvals ra
-- JOIN reservations r ON ra.reservation_id = r.reservation_id
-- JOIN users u ON ra.follow_up_requested_by = u.user_id
-- JOIN offices o ON ra.office_id = o.office_id
-- WHERE ra.follow_up_requested = true
-- AND ra.status = 'pending'
-- ORDER BY ra.follow_up_requested_at DESC;
--
-- This will give you all pending approvals that have follow-up requests,
-- along with the reservation details, who requested the follow-up, and
-- which office needs to be notified.
-- ============================================================================