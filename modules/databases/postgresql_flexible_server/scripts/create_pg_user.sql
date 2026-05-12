-- Create database user and assign role
-- Assumes login (server-level role) already exists from create_pg_login.sql

DO $$
DECLARE
    v_dbusernames VARCHAR(1000) := :'DBUSERNAMES';
    v_dbroles VARCHAR(1000) := :'DBROLES';
    v_username VARCHAR(100);
    v_dbrole VARCHAR(100);
    v_sql VARCHAR(500);
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

        -- Assign role from the login
        v_sql := 'GRANT "' || :'DBROLES' || '" TO "' || v_username || '"';
        EXECUTE v_sql;
        RAISE NOTICE 'User % assigned to role %', v_username, :'DBROLES';
    END LOOP;
END
$$;
