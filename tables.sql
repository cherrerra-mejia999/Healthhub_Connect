CREATE DATABASE IF NOT EXISTS HealthHubDB
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;
USE HealthHubDB;

-- Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    role ENUM('patient', 'doctor', 'admin') DEFAULT 'patient'
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Profiles Table
CREATE TABLE Profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender ENUM('male', 'female', 'other') NOT NULL,
    insurance_id VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_profiles_user (user_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Foreign Key Constraint
ALTER TABLE Profiles
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id) REFERENCES Users(user_id)
ON DELETE CASCADE;

-- Daily_Tracker Table
CREATE TABLE Daily_Tracker (
    tracker_id int auto_increment primary key,
    user_id int not null,
    date date not null,
    heart_rate int,
    blood_pressure VARCHAR(10),
    sleep_cycles_hours DECIMAL(5,2),
    steps int,
    calories_burned int,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    UNIQUE KEY uk_tracker_user_date (user_id, date),
    KEY idx_tracker_date (date)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Call_Center Table
CREATE TABLE Call_Center (
    call_id INT auto_increment PRIMARY KEY,
    user_id INT NOT NULL,
    agent_namme VARCHAR(100),
    issue_type ENUM('technical', 'billing', 'general') NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Docments Table
CREATE TABLE Documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    document_type ENUM('prescription', 'lab_report', 'imaging', 'other') NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    KEY idx_documents_user (user_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Medications Table
CREATE TABLE Medications (
    medication_id int auto_increment primary key,
    user_id int not null,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    start_date DATE,
    end_date DATE,
    refill_date DATE,
    Foreign Key (user_id) REFERENCES Users(user_id) on delete cascade,
    KEY idx_medications_user (user_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

