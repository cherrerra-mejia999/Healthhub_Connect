-- Migration: Add Medication Schedule Feature
-- This migration adds the medication_schedule table and RPC function
-- to enable daily medication tracking from start date to end/refill date.

-- Step 1: Add missing columns to medications table
ALTER TABLE medications
ADD COLUMN IF NOT EXISTS time_of_day TEXT[],
ADD COLUMN IF NOT EXISTS prescribing_doctor VARCHAR(100),
ADD COLUMN IF NOT EXISTS pharmacy_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Step 2: Create medication_schedule table
CREATE TABLE IF NOT EXISTS medication_schedule (
    schedule_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    medication_id UUID REFERENCES medications(medication_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    is_taken BOOLEAN DEFAULT false,
    skipped BOOLEAN DEFAULT false,
    taken_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(medication_id, scheduled_date, scheduled_time)
);

-- Step 3: Enable Row Level Security
ALTER TABLE medication_schedule ENABLE ROW LEVEL SECURITY;

-- Step 4: Add RLS policy
CREATE POLICY IF NOT EXISTS "Medication schedule is user specific"
ON medication_schedule FOR ALL
USING (auth.uid() = user_id);

-- Step 5: Create function to generate medication schedule
CREATE OR REPLACE FUNCTION generate_medication_schedule(
    med_id UUID,
    u_id UUID,
    times TEXT[],
    start_date DATE,
    days_ahead INTEGER
)
RETURNS VOID AS $$
DECLARE
    current_date DATE;
    time_val TEXT;
    end_date DATE;
BEGIN
    -- Calculate end date
    end_date := start_date + days_ahead;

    -- Delete existing schedule entries for this medication to avoid duplicates
    DELETE FROM medication_schedule
    WHERE medication_id = med_id;

    -- Loop through each day
    current_date := start_date;
    WHILE current_date <= end_date LOOP
        -- For each time in the times array
        FOREACH time_val IN ARRAY times LOOP
            -- Insert schedule entry
            INSERT INTO medication_schedule (
                medication_id,
                user_id,
                scheduled_date,
                scheduled_time,
                is_taken,
                skipped
            ) VALUES (
                med_id,
                u_id,
                current_date,
                time_val::TIME,
                false,
                false
            )
            ON CONFLICT (medication_id, scheduled_date, scheduled_time) DO NOTHING;
        END LOOP;

        -- Move to next day
        current_date := current_date + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION generate_medication_schedule TO authenticated;
