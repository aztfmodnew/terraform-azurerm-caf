-- Set PostgreSQL database permissions for users/groups/managed identities
-- Creates external provider roles (AAD/Managed Identity) and assigns permissions

DO $$
DECLARE
    v_dbusernames VARCHAR(2000) := :'DBUSERNAMES';
    v_dbroles VARCHAR(2000) := :'DBROLES';
    v_username VARCHAR(100);
    v_role VARCHAR(100);
    v_sql VARCHAR(500);
    v_roles_list VARCHAR(2000);
BEGIN
    WHILE LENGTH(v_dbusernames) > 0 LOOP
        -- Extract first username
        IF POSITION(',' IN v_dbusernames) > 0 THEN
            v_username := SUBSTRING(v_dbusernames FROM 1 FOR POSITION(',' IN v_dbusernames) - 1);
            v_dbusernames := SUBSTRING(v_dbusernames FROM POSITION(',' IN v_dbusernames) + 1);
        ELSE
            v_username := v_dbusernames;
            v_dbusernames := '';
        END IF;

        v_username := TRIM(v_username);

        -- Create role from external provider (AAD / Managed Identity) if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = v_username) THEN
            v_sql := 'CREATE ROLE "' || v_username || '" WITH LOGIN';
            BEGIN
                EXECUTE v_sql;
                RAISE NOTICE 'User % created from external provider', v_username;
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'User % already exists or error creating: %', v_username, SQLERRM;
            END;
        ELSE
            RAISE NOTICE 'User % already exists', v_username;
        END IF;

        -- Assign roles to the user
        v_roles_list := :'DBROLES';
        WHILE LENGTH(v_roles_list) > 0 LOOP
            IF POSITION(',' IN v_roles_list) > 0 THEN
                v_role := SUBSTRING(v_roles_list FROM 1 FOR POSITION(',' IN v_roles_list) - 1);
                v_roles_list := SUBSTRING(v_roles_list FROM POSITION(',' IN v_roles_list) + 1);
            ELSE
                v_role := v_roles_list;
                v_roles_list := '';
            END IF;

            v_role := TRIM(v_role);

            -- Grant role to user
            BEGIN
                v_sql := 'GRANT "' || v_role || '" TO "' || v_username || '"';
                EXECUTE v_sql;
                RAISE NOTICE 'Granted role % to user %', v_role, v_username;
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'Error granting role % to user %: %', v_role, v_username, SQLERRM;
            END;
        END LOOP;
    END LOOP;
END
$$;
