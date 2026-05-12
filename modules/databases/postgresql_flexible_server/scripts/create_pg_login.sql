-- Create PostgreSQL login (server-level role)
-- Single user per call from Terraform

DO $$
BEGIN
    -- Check if login already exists
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'DBUSERNAMES') THEN
        EXECUTE 'CREATE USER "' || :'DBUSERNAMES' || '" WITH LOGIN PASSWORD ' || quote_literal(:'DBUSERPASSWORDS');
        RAISE NOTICE 'Login created: %', :'DBUSERNAMES';
    ELSE
        RAISE NOTICE 'Login already exists: %', :'DBUSERNAMES';
    END IF;
END
$$;
