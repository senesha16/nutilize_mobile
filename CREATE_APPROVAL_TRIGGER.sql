-- ============================================================================
-- REFERENCE: Approval Logic Documentation
-- ============================================================================
-- IMPORTANT: This file documents the approval workflow logic.
-- The actual approval creation is handled by your existing web system.
--
-- Approval Chain Logic:
-- - If item owner IS "Physical Facilities": 
--   Program Chair → SDAO → DO → Security → Physical Facilities (5 stages)
-- - If item owner is NOT "Physical Facilities": 
--   [Item Owner] → Program Chair → SDAO → DO → Security → Physical Facilities (6+ stages)
--
-- The mobile app will dynamically show/hide the "Designated Item Owner" stage
-- based on whether the reservation items belong to Physical Facilities or not.
-- ============================================================================

-- NOTE: DO NOT RUN THIS TRIGGER - your web system already handles approval creation
-- This is kept for reference only

/*
-- If you need to create approvals automatically in the database, uncomment this:

DROP TRIGGER IF EXISTS create_approvals_on_item_add ON reservation_items CASCADE;
DROP FUNCTION IF EXISTS create_reservations_approvals() CASCADE;

CREATE OR REPLACE FUNCTION create_reservations_approvals()
RETURNS TRIGGER AS $$
DECLARE
  v_reservation_id bigint;
  v_owner_id bigint;
  v_owner_name varchar;
  v_owner_office_id bigint;
  v_existing_approvals_count bigint;
  v_office_id bigint;
BEGIN
  -- Get reservation_id from reservation_details
  SELECT rd.reservation_id INTO v_reservation_id
  FROM reservation_details rd
  WHERE rd.reservation_items_id = NEW.reservation_items_id
  LIMIT 1;

  IF v_reservation_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Check if approvals already exist
  SELECT COUNT(*) INTO v_existing_approvals_count
  FROM reservation_approvals
  WHERE reservation_id = v_reservation_id;

  IF v_existing_approvals_count > 0 THEN
    RETURN NEW;
  END IF;

  -- Get the item owner
  SELECT io.owner_name INTO v_owner_name
  FROM items i
  JOIN item_owners io ON i.owner_id = io.owner_id
  WHERE i.item_id = NEW.item_id;

  -- Add item owner approval if NOT Physical Facilities
  IF v_owner_name IS NOT NULL AND v_owner_name != 'Physical Facilities' THEN
    SELECT office_id INTO v_owner_office_id
    FROM offices
    WHERE department_name = v_owner_name
    LIMIT 1;

    IF v_owner_office_id IS NOT NULL THEN
      INSERT INTO reservation_approvals (reservation_id, office_id, status, created_at, updated_at)
      VALUES (v_reservation_id, v_owner_office_id, 'pending', NOW(), NOW());
    END IF;
  END IF;

  -- Add standard approval chain
  FOR v_office_id IN
    SELECT office_id
    FROM offices
    WHERE department_name IN ('Program Chair', 'SDAO', 'DO', 'Security', 'Physical Facilities')
    ORDER BY order_sequence ASC
  LOOP
    INSERT INTO reservation_approvals (reservation_id, office_id, status, created_at, updated_at)
    VALUES (v_reservation_id, v_office_id, 'pending', NOW(), NOW());
  END LOOP;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error in create_reservations_approvals: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_approvals_on_item_add
AFTER INSERT ON reservation_items
FOR EACH ROW
EXECUTE FUNCTION create_reservations_approvals();

*/

-- ============================================================================
-- INSTRUCTIONS FOR DEPLOYMENT
-- ============================================================================
-- 1. Verify that your offices table has these department_name values:
--    - "Program Chair"
--    - "SDAO"
--    - "DO"
--    - "Security"
--    - "Physical Facilities"
--    - Any other item owner departments (e.g., "IT", "Facilities Management", etc.)
--
-- 2. Ensure order_sequence is set correctly for all offices that will be used
--    in the approval chain.
--
-- 3. Ensure item_owners table has correct owner_name values that match
--    office department_name values (for designated owner approvals).
--
-- 4. Copy this entire SQL file
-- 5. Open Supabase Dashboard → SQL Editor
-- 6. Create a NEW query
-- 7. Paste this entire SQL
-- 8. Click "Run"
-- 9. Verify the trigger was created (check Functions and Triggers section)
--
-- VERIFICATION QUERY:
-- Run these queries to verify everything is set up correctly:
-- SELECT office_id, department_name, order_sequence FROM offices ORDER BY order_sequence;
-- SELECT owner_id, owner_name FROM item_owners;
-- ============================================================================

