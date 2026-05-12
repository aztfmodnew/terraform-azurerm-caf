-- Grant database role to user
-- Assigns predefined PostgreSQL role to user account

DO $$
BEGIN
    -- Grant the specified role to the user
    EXECUTE 'GRANT "' || :'DBROLES' || '" TO "' || :'DBUSERNAMES' || '"';
    RAISE NOTICE 'User % assigned to role %', :'DBUSERNAMES', :'DBROLES';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error assigning role: %', SQLERRM;
END
$$;
