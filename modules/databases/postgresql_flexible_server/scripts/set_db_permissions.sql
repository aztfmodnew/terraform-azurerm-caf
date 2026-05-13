-- Set PostgreSQL database permissions for managed identities and AAD groups
-- Handles multiple comma-separated usernames and roles

DO $$
DECLARE
    v_usernames TEXT := :'DBUSERNAMES';
    v_roles TEXT := :'DBROLES';
    v_username TEXT;
    v_role TEXT;
    v_user_array TEXT[];
    v_role_array TEXT[];
BEGIN
    -- Remove surrounding quotes and split by comma
    v_usernames := TRIM(BOTH '''' FROM v_usernames);
    v_roles := TRIM(BOTH '''' FROM v_roles);
    
    v_user_array := STRING_TO_ARRAY(v_usernames, ',');
    v_role_array := STRING_TO_ARRAY(v_roles, ',');
    
    -- Process each username
    FOREACH v_username IN ARRAY v_user_array LOOP
        v_username := TRIM(v_username);
        
        -- Create role from external provider (AAD/Managed Identity) if needed
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_username) THEN
            BEGIN
                EXECUTE 'CREATE ROLE "' || v_username || '" WITH LOGIN';
                RAISE NOTICE 'Role created for: %', v_username;
            EXCEPTION WHEN duplicate_object THEN
                RAISE NOTICE 'Role already exists: %', v_username;
            WHEN OTHERS THEN
                RAISE NOTICE 'Warning creating role %: %', v_username, SQLERRM;
            END;
        END IF;
        
        -- Grant each role to the user
        FOREACH v_role IN ARRAY v_role_array LOOP
            v_role := TRIM(v_role);
            IF v_role <> '' THEN
                BEGIN
                    EXECUTE 'GRANT "' || v_role || '" TO "' || v_username || '"';
                    RAISE NOTICE 'Granted role % to user %', v_role, v_username;
                EXCEPTION WHEN OTHERS THEN
                    RAISE NOTICE 'Warning granting role %: %', v_role, SQLERRM;
                END;\n            END IF;\n        END LOOP;\n    END LOOP;\nEND\n$$;
