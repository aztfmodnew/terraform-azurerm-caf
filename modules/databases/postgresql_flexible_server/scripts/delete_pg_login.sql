-- Delete PostgreSQL login (server-level role)
-- Cleanup procedure on destroy

DO $$
BEGIN
    -- Check if login exists
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'DBUSERNAMES') THEN
        -- Reassign owned objects to current admin
        EXECUTE 'REASSIGN OWNED BY "' || :'DBUSERNAMES' || '" TO current_user';
        
        -- Drop owned objects
        EXECUTE 'DROP OWNED BY "' || :'DBUSERNAMES' || '"';
        
        -- Drop the role/login
        EXECUTE 'DROP ROLE IF EXISTS "' || :'DBUSERNAMES' || '"';
        RAISE NOTICE 'Login deleted: %', :'DBUSERNAMES';
    ELSE
        RAISE NOTICE 'Login does not exist: %', :'DBUSERNAMES';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error deleting login: %', SQLERRM;
END
$$;
