-- Fix for appointment booking issue where completed appointments block new bookings
-- This migration removes overly restrictive unique constraints and replaces them with
-- partial unique indexes that only apply to active (pending/confirmed) appointments

-- Drop any existing unique constraints that don't account for appointment status
-- (These may or may not exist depending on your database setup)
-- Note: Run these DROP statements if the constraints exist in your database

-- Example of constraints that might be causing issues:
-- DROP INDEX IF EXISTS appointments_doctor_date_time_unique;
-- DROP INDEX IF EXISTS appointments_user_doctor_date_unique;
-- DROP INDEX IF EXISTS appointments_user_doctor_date_time_unique;

-- Create a partial unique index to prevent double-booking of doctor time slots
-- This only applies to pending and confirmed appointments, allowing completed/cancelled appointments
-- to not block future bookings
CREATE UNIQUE INDEX IF NOT EXISTS appointments_doctor_active_slot_unique
ON appointments (doctor_id, appointment_date, appointment_time)
WHERE status IN ('pending', 'confirmed');

-- Optional: Prevent a user from having multiple active appointments at the same time
-- (Uncomment if you want to prevent users from booking overlapping appointments)
-- CREATE UNIQUE INDEX IF NOT EXISTS appointments_user_active_datetime_unique
-- ON appointments (user_id, appointment_date, appointment_time)
-- WHERE status IN ('pending', 'confirmed');

-- Add a comment to document this constraint
COMMENT ON INDEX appointments_doctor_active_slot_unique IS
'Prevents double-booking of doctor time slots for active appointments only. Completed and cancelled appointments do not block future bookings.';
