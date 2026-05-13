-- Create PostgreSQL login (server-level role)
-- Single user per call from Terraform

\echo 'Creating user:' :DBUSERNAMES

CREATE ROLE :DBUSERNAMES WITH LOGIN PASSWORD :'DBUSERPASSWORDS';

\echo 'User created successfully'
