-- Fix RLS policy for documents table to allow doctors to upload documents for patients
-- This migration removes the overly restrictive policy and creates role-based policies

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Documents are user specific" ON documents;

-- Create separate policies for different operations with role-based access

-- SELECT Policy: Users can view their own documents, doctors/admins can view all documents
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

-- INSERT Policy: Users can insert their own documents, doctors/admins can insert for anyone
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

-- UPDATE Policy: Users can update their own documents, doctors/admins can update any documents
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

-- DELETE Policy: Users can delete their own documents, doctors/admins can delete any documents
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

-- Add comments to document the policies
COMMENT ON POLICY "Documents select policy" ON documents IS
'Allows users to view their own documents. Doctors and admins can view all patient documents.';

COMMENT ON POLICY "Documents insert policy" ON documents IS
'Allows users to upload their own documents. Doctors and admins can upload documents for any patient.';

COMMENT ON POLICY "Documents update policy" ON documents IS
'Allows users to update their own documents. Doctors and admins can update any documents.';

COMMENT ON POLICY "Documents delete policy" ON documents IS
'Allows users to delete their own documents. Doctors and admins can delete any documents.';
