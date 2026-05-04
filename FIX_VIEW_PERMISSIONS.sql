-- Run this in Supabase SQL Editor
-- Ensures authenticated users can query the new public views

GRANT USAGE ON SCHEMA public TO authenticated;

GRANT SELECT ON public.v_reservations_public TO authenticated;
GRANT SELECT ON public.v_reservation_details_public TO authenticated;
GRANT SELECT ON public.v_reservation_items_public TO authenticated;
GRANT SELECT ON public.v_reservation_rooms_public TO authenticated;
GRANT SELECT ON public.v_reservation_rooms_details TO authenticated;
GRANT SELECT ON public.v_reservation_items_details TO authenticated;

-- Optional: allow anon too (if your app uses anon role before auth)
-- GRANT USAGE ON SCHEMA public TO anon;
-- GRANT SELECT ON public.v_reservations_public TO anon;
-- GRANT SELECT ON public.v_reservation_details_public TO anon;
-- GRANT SELECT ON public.v_reservation_items_public TO anon;
-- GRANT SELECT ON public.v_reservation_rooms_public TO anon;
-- GRANT SELECT ON public.v_reservation_rooms_details TO anon;
-- GRANT SELECT ON public.v_reservation_items_details TO anon;
