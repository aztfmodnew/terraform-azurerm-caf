-- Revoke database roles and privileges
-- Cleanup before login deletion

DO $$
BEGIN
    -- Revoke all privileges on all tables in public schema
    EXECUTE 'REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "' || :'DBUSERNAMES' || '"';
    
    -- Revoke default privileges
    EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM "' || :'DBUSERNAMES' || '"';
    
    -- Revoke all database grants
    EXECUTE 'REVOKE ALL PRIVILEGES ON DATABASE "' || current_database() || '" FROM "' || :'DBUSERNAMES' || '"';
    
    RAISE NOTICE 'Privileges revoked for user: %', :'DBUSERNAMES';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error revoking privileges: %', SQLERRM;
END
$$;
