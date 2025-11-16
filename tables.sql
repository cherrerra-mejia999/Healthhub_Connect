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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_tracker ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_center ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only see their own data
CREATE POLICY "Users can view own data" ON users FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Profiles are user specific" ON profiles FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Tracker data is user specific" ON daily_tracker FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Call center data is user specific" ON call_center FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Medications are user specific" ON medications FOR ALL USING (auth.uid() = user_id);

-- Documents Policies: Role-based access to allow doctors to manage patient documents
CREATE POLICY "Documents select policy" ON documents
FOR SELECT
USING (
    auth.uid() = user_id OR  -- Users can view their own documents
    EXISTS (
        SELECT 1 FROM users
        WHERE users.user_id = auth.uid()
        AND users.role IN ('doctor', 'admin')  -- Doctors and admins can view all documents
    )
);

CREATE POLICY "Documents insert policy" ON documents
FOR INSERT
WITH CHECK (
    auth.uid() = user_id OR  -- Users can insert their own documents
    EXISTS (
        SELECT 1 FROM users
        WHERE users.user_id = auth.uid()
        AND users.role IN ('doctor', 'admin')  -- Doctors and admins can insert for any patient
    )
);

CREATE POLICY "Documents update policy" ON documents
FOR UPDATE
USING (
    auth.uid() = user_id OR  -- Users can update their own documents
    EXISTS (
        SELECT 1 FROM users
        WHERE users.user_id = auth.uid()
        AND users.role IN ('doctor', 'admin')  -- Doctors and admins can update any documents
    )
);

CREATE POLICY "Documents delete policy" ON documents
FOR DELETE
USING (
    auth.uid() = user_id OR  -- Users can delete their own documents
    EXISTS (
        SELECT 1 FROM users
        WHERE users.user_id = auth.uid()
        AND users.role IN ('doctor', 'admin')  -- Doctors and admins can delete any documents
    )
);

