-- Create PostgreSQL login (server-level role)
-- Single user per call from Terraform

CREATE USER :'DBUSERNAMES' WITH LOGIN PASSWORD :'DBUSERPASSWORDS';
