#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

echo "Setting database permissions for users: ${DBUSERNAMES}"

# Generate SQL dynamically with proper variable substitution
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "${PGDATABASE}" << EOSQL
DO \\\$\\\$
DECLARE
    v_usernames TEXT := '$(echo "${DBUSERNAMES}" | sed "s/'/''/g")';
    v_roles TEXT := '$(echo "${DBROLES}" | sed "s/'/''/g")';
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
    
    RAISE NOTICE 'Processing users: %', v_usernames;
    RAISE NOTICE 'Assigning roles: %', v_roles;
    
    -- Process each username
    FOREACH v_username IN ARRAY v_user_array LOOP
        v_username := TRIM(v_username);
        
        -- Create role from external provider (AAD/Managed Identity) if needed
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_username) THEN
            BEGIN
                EXECUTE 'CREATE ROLE ' || quote_identifier(v_username) || ' WITH LOGIN';
                RAISE NOTICE 'Role created for: %', v_username;
            EXCEPTION WHEN duplicate_object THEN
                RAISE NOTICE 'Role already exists: %', v_username;
            WHEN OTHERS THEN
                RAISE NOTICE 'Warning creating role: %', SQLERRM;
            END;
        END IF;
        
        -- Grant each role to the user
        FOREACH v_role IN ARRAY v_role_array LOOP
            v_role := TRIM(v_role);
            IF v_role <> '' THEN
                BEGIN
                    EXECUTE 'GRANT ' || quote_identifier(v_role) || ' TO ' || quote_identifier(v_username);
                    RAISE NOTICE 'Granted role % to user %', v_role, v_username;
                EXCEPTION WHEN OTHERS THEN
                    RAISE NOTICE 'Warning granting role: %', SQLERRM;
                END;
            END IF;
        END LOOP;
    END LOOP;
END
\\\$\\\$;
EOSQL

echo "PostgreSQL database permissions set successfully"
