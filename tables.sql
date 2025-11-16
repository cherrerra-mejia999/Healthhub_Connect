-- Users Table
CREATE TABLE users (
    user_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    date_of_birth DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    role VARCHAR(20) DEFAULT 'patient' CHECK (role IN ('patient', 'doctor', 'admin'))
);

-- Profiles Table
CREATE TABLE profiles (
    profile_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10) DEFAULT 'other' CHECK (gender IN ('male', 'female', 'other')),
    insurance_id VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(user_id)
);

-- Daily Tracker Table
CREATE TABLE daily_tracker (
    tracker_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    heart_rate INTEGER,
    blood_pressure VARCHAR(10),
    sleep_cycles_hours DECIMAL(5,2),
    steps INTEGER,
    calories_burned INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(user_id, date)
);

-- Call Center Table
CREATE TABLE call_center (
    call_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    agent_name VARCHAR(100),
    issue_type VARCHAR(20) CHECK (issue_type IN ('technical', 'billing', 'general')),
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Documents Table
CREATE TABLE documents (
    document_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    document_type VARCHAR(20) CHECK (document_type IN ('prescription', 'lab_report', 'imaging', 'other')),
    file_path VARCHAR(255) NOT NULL,
    file_name VARCHAR(255),
    file_size INTEGER,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Medications Table
CREATE TABLE medications (
    medication_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    start_date DATE,
    end_date DATE,
    refill_date DATE,
    time_of_day TEXT[],
    prescribing_doctor VARCHAR(100),
    pharmacy_name VARCHAR(100),
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Medication Schedule Table
CREATE TABLE medication_schedule (
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

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_tracker ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_center ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_schedule ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only see their own data
CREATE POLICY "Users can view own data" ON users FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Profiles are user specific" ON profiles FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Tracker data is user specific" ON daily_tracker FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Call center data is user specific" ON call_center FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Documents are user specific" ON documents FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Medications are user specific" ON medications FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Medication schedule is user specific" ON medication_schedule FOR ALL USING (auth.uid() = user_id);

-- Function to generate medication schedule
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

