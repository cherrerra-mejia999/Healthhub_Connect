# Healthhub Connect

A comprehensive healthcare management system that connects patients with healthcare providers, enabling appointment booking, health tracking, document management, and AI-powered health assistance.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Running the Project](#running-the-project)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Dependencies](#dependencies)

---

## Overview

Healthhub Connect is a web-based healthcare management platform designed to streamline the interaction between patients and healthcare providers. The system allows patients to book and manage appointments, track daily health metrics, upload medical documents, and communicate with an AI health chatbot. Healthcare providers can manage their availability, view patient appointments, and access patient information securely through a dedicated dashboard.

---

## Key Features

### Patient Features
- **User Authentication**: Secure sign-in and sign-up system with email verification
- **Appointment Booking**: Search for doctors by specialization and location, book appointments with available time slots
- **Appointment Management**: View upcoming appointments, reschedule, and cancel bookings
- **Daily Health Tracker**: Log blood pressure, glucose levels, weight, temperature, and other vital signs
- **Document Management**: Upload and store medical records, prescriptions, lab results, and test reports
- **AI Health Chatbot**: Receive instant answers to health-related questions and guidance
- **Medication Tracker**: Maintain records of current medications and prescriptions
- **Family Dashboard**: Manage health information for family members in one centralized location
- **Health Resources**: Access educational content, emergency contacts, and helpful health tips

### Healthcare Provider Features
- **Doctor Registration**: Register with medical credentials, license number, and specialization
- **Appointment Management**: View, confirm, and manage patient appointments
- **Doctor Dashboard**: Overview of daily schedule, patient information, and appointment history
- **Profile Management**: Update availability, specialization, and contact information

### Security Features
- Email verification required for new user accounts
- Role-based access control distinguishing between patients and healthcare providers
- Secure password requirements with strength validation
- Protected routes requiring authentication before access
- Database-level security implemented with Supabase Row Level Security (RLS)
- HIPAA-compliant data handling practices

---

## Technologies Used

### Frontend
- **HTML5**: Semantic markup and document structure
- **CSS3**: Custom styling with modern CSS features and responsive design
- **JavaScript (ES6+)**: Client-side logic, DOM manipulation, and API integration
- **Responsive Design**: Mobile-first approach ensuring compatibility across all device sizes

### Backend & Database
- **Supabase**: 
  - PostgreSQL relational database
  - Built-in authentication service
  - Real-time data subscriptions
  - Row Level Security (RLS) policies
  - RESTful API endpoints

### Testing
- **Jest**: JavaScript testing framework (equivalent to JUnit for Java)
- **Node.js**: JavaScript runtime environment for test execution
- **npm**: Package manager for dependency management

### Version Control
- **Git**: Distributed version control system
- **GitHub**: Remote repository hosting and team collaboration

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:

### Required Software
- **Web Browser**: Chrome 90+, Firefox 88+, Safari 14+, or Microsoft Edge 90+ (latest versions recommended)
- **Text Editor/IDE**: Visual Studio Code (recommended), Sublime Text, Atom, or similar code editor
- **Git**: Version control system for cloning the repository
- **Node.js**: Version 14.0.0 or higher (required for running tests)
- **npm**: Version 6.0.0 or higher (included with Node.js installation)

### Optional Tools
- **Supabase Account**: For database administration (credentials already configured in project)
- **VS Code Extensions**: 
  - Live Server (for local development)
  - Prettier (code formatting)
  - ESLint (code linting)

---

## Installation & Setup

### Step 1: Clone the Repository

```bash
# Using HTTPS
git clone https://github.com/cherrerra-mejia999/Healthhub_Connect.git

# Or using SSH
git clone git@github.com:cherrerra-mejia999/Healthhub_Connect.git

# Navigate to project directory
cd Healthhub_Connect
```

### Step 2: Open Project in Code Editor

**Using VS Code:**
```bash
code .
```

**Or manually:**
- Open Visual Studio Code
- Select File → Open Folder
- Navigate to and select the `Healthhub_Connect` directory

### Step 3: Install Node.js Dependencies (For Testing)

```bash
# Initialize npm package (if not already initialized)
npm init -y

# Install Jest testing framework
npm install --save-dev jest

# Install Supabase client library for tests
npm install --save-dev @supabase/supabase-js
```

### Step 4: Configure package.json

Open `package.json` and ensure the test script is properly configured:

```json
{
  "name": "healthhub_connect",
  "version": "1.0.0",
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "@supabase/supabase-js": "^2.39.0"
  }
}
```

### Step 5: Verify Supabase Configuration

The project includes pre-configured Supabase credentials. The Supabase JavaScript client is loaded via CDN in each HTML file:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
```

**Security Note**: For production deployment, move API keys to environment variables and implement proper key rotation policies.

---

## Running the Project

### Method 1: Using Live Server (Recommended for Development)

1. Install the **Live Server** extension in Visual Studio Code
2. Right-click on `index.html` in the VS Code file explorer
3. Select "Open with Live Server"
4. The application will open in your default browser at `http://localhost:5500`

### Method 2: Using Python HTTP Server

```bash
# For Python 3.x
python3 -m http.server 8000

# For Python 2.x
python -m SimpleHTTPServer 8000
```

After starting the server, navigate to `http://localhost:8000` in your web browser.

### Method 3: Direct File Access

Double-click the `index.html` file to open it directly in your default web browser.

**Important Note**: Some features, particularly Supabase database connections and CORS-dependent functionality, may not work correctly when using the `file://` protocol. For full functionality, use Live Server or a local HTTP server.

---

## Testing

The project implements automated testing using Jest, a JavaScript testing framework equivalent to JUnit for Java applications.

### Test Environment Setup

#### Windows Installation:

1. **Install Node.js**
   - Download the LTS version from https://nodejs.org/
   - Run the installer with default settings
   - Restart Command Prompt or VS Code terminal after installation completes

2. **Verify Installation**
   ```bash
   node --version
   npm --version
   ```

3. **Install Test Dependencies**
   ```bash
   npm install --save-dev jest @supabase/supabase-js
   ```

4. **Configure Terminal (If Using PowerShell)**
   - If encountering execution policy errors in PowerShell
   - Switch to Command Prompt in VS Code terminal dropdown menu
   - Alternatively, run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

#### macOS Installation:

1. **Install Node.js**
   - Download the LTS version from https://nodejs.org/
   - Or install via Homebrew: `brew install node`

2. **Verify Installation**
   ```bash
   node --version
   npm --version
   ```

3. **Install Test Dependencies**
   ```bash
   npm install --save-dev jest @supabase/supabase-js
   ```

### Running Tests

Execute the following commands in your terminal:

```bash
# Run all test suites
npm test

# Run tests in watch mode (automatically reruns on file changes)
npm test -- --watch

# Generate code coverage report
npm test -- --coverage

# Run specific test file
npm test healthub_core_tests.test.js
```

---

## Project Structure

The project follows a standard web application structure with HTML pages for different features, a test suite for quality assurance, and configuration files for dependency management.

---

## Configuration

### Supabase Database Configuration

The application utilizes Supabase as its backend-as-a-service platform. Configuration credentials are embedded within the HTML files:

```javascript
const supabaseUrl = 'https://hbtgwzneuhdqlmriwvje.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
const supabase = window.supabase.createClient(supabaseUrl, supabaseKey);
```

**Database Schema:**

The following tables are implemented in the PostgreSQL database:

- `users` - User authentication credentials and profile information
- `doctors` - Healthcare provider credentials, licenses, and specializations
- `appointments` - Appointment bookings with patient-doctor associations
- `health_tracker` - Daily health metrics and vital sign records
- `documents` - Uploaded medical documents and file metadata
- `medications` - Medication records and prescription information

---

## Dependencies

### Runtime Dependencies (CDN)

The following dependencies are loaded via Content Delivery Network:

- **Supabase JavaScript Client v2**: Provides authentication and database operations
  - CDN: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js`
- **Browser Compatibility**: Modern browsers supporting ES6+ JavaScript

**Minimum Browser Versions:**
- Google Chrome: 90+
- Mozilla Firefox: 88+
- Safari: 14+
- Microsoft Edge: 90+

### Development Dependencies (npm)

Installed via npm for local development and testing:

```json
{
  "devDependencies": {
    "jest": "^29.7.0",
    "@supabase/supabase-js": "^2.39.0"
  }
}
```

### Testing Framework Components

**Jest Testing Framework:**
- Assertion library for test validation
- Mock function capabilities for Supabase API simulation
- Code coverage reporting tools
- Parallel test execution for improved performance
- Watch mode for test-driven development

---



