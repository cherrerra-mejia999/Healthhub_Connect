# Document Upload RLS Fix

## Problem
Doctors were unable to upload documents for patients due to overly restrictive Row-Level Security (RLS) policies on the `documents` table.

## Error Message
```
Error uploading document: new row violates row-level security policy
```

## Root Cause
The previous RLS policy only allowed users to manage documents where `auth.uid() = user_id`. This prevented doctors from uploading documents on behalf of patients.

## Solution
The RLS policy has been updated to use role-based access control:
- **Patients**: Can view, upload, update, and delete their own documents
- **Doctors**: Can view, upload, update, and delete documents for any patient
- **Admins**: Can view, upload, update, and delete any documents

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
After applying the fix:
1. Log in as a doctor
2. Open a patient's record in the doctor dashboard
3. Navigate to the "Upload Document" tab
4. Select a document type and file
5. Click "Upload Document"
6. The upload should now succeed without RLS errors

## Files Modified
- `fix_document_upload_rls.sql` - Migration script to fix existing databases
- `tables.sql` - Updated base schema with corrected RLS policies
- `APPLY_DOCUMENT_RLS_FIX.md` - This instruction file

## Technical Details
The new policies check the user's role in the `users` table:
```sql
EXISTS (
    SELECT 1 FROM users
    WHERE users.user_id = auth.uid()
    AND users.role IN ('doctor', 'admin')
)
```

This allows doctors and admins to perform operations on documents regardless of the `user_id` field.
