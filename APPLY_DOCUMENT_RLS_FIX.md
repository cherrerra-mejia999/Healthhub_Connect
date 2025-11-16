# Documents & Medications RLS Fix

## Problem
Doctors were unable to upload documents or add medications for patients due to overly restrictive Row-Level Security (RLS) policies on the `documents` and `medications` tables.

## Error Messages
```
Error uploading document: new row violates row-level security policy
Error adding medication: new row violates row-level security policy for table "medications"
```

## Root Cause
The previous RLS policies only allowed users to manage data where `auth.uid() = user_id`. This prevented doctors from:
- Uploading documents on behalf of patients
- Prescribing/adding medications for patients

## Solution
The RLS policies have been updated to use role-based access control:

### Documents Table
- **Patients**: Can view, upload, update, and delete their own documents
- **Doctors**: Can view, upload, update, and delete documents for any patient
- **Admins**: Can view, upload, update, and delete any documents

### Medications Table
- **Patients**: Can view, add, update, and delete their own medications
- **Doctors**: Can view, prescribe, update, and delete medications for any patient
- **Admins**: Can view, add, update, and delete any medications

## How to Apply the Fix

### Option 1: Run Migration Script (Recommended)
1. Open your Supabase dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of `fix_document_upload_rls.sql`
4. Paste and run the SQL script
5. The script will automatically drop the old policy and create the new role-based policies

### Option 2: Manual Application
If you're setting up a new database, the corrected policies are already included in `tables.sql`.

## Verification
After applying the fix, test both features:

### Test Document Upload
1. Log in as a doctor
2. Open a patient's record in the doctor dashboard
3. Navigate to the "Upload Document" tab
4. Select a document type and file
5. Click "Upload Document"
6. The upload should now succeed without RLS errors

### Test Medication Prescription
1. Log in as a doctor
2. Open a patient's record in the doctor dashboard
3. Navigate to the "Add Medication" tab
4. Fill in medication details (name, dosage, frequency, etc.)
5. Click "Add Medication"
6. The medication should be added without RLS errors

## Files Modified
- `fix_document_upload_rls.sql` - Comprehensive migration script for both documents and medications
- `tables.sql` - Updated base schema with corrected RLS policies (reference only)
- `APPLY_DOCUMENT_RLS_FIX.md` - This instruction file

## Technical Details
The new policies check if the authenticated user is a doctor by querying the `public.doctors` table:

```sql
-- For both documents and medications tables:
-- Check if user is a doctor
EXISTS (
    SELECT 1 FROM public.doctors
    WHERE public.doctors.user_id = auth.uid()
)
-- OR check if user is an admin
OR EXISTS (
    SELECT 1 FROM public.users
    WHERE public.users.user_id = auth.uid()
    AND public.users.role = 'admin'
)
```

This allows:
- **Doctors**: Any user with an entry in the `public.doctors` table can manage patient data
- **Admins**: Any user with role='admin' in `public.users` can manage patient data
- **Patients**: Can only manage their own data (when `auth.uid() = user_id`)

### Important Notes
- The migration script handles both `documents` and `medications` tables
- Each table gets 4 separate policies: SELECT, INSERT, UPDATE, DELETE
- The policies use `auth.uid()` to get the current authenticated user's ID
- **Doctor identification**: Checks if `auth.uid()` exists in `public.doctors` table
- **Admin identification**: Checks if user has role='admin' in `public.users` table
- Existing restrictive policies are automatically dropped before creating new ones

### Why This Works
When a doctor logs in through Supabase Auth, their `auth.uid()` corresponds to their `user_id` in the `public.doctors` table. The RLS policies check this relationship directly, allowing any authenticated doctor to manage patient documents and medications.
