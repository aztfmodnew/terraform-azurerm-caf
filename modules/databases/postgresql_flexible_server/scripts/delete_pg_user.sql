-- Delete database user role
-- This removes the user from the database

DO $$
DECLARE
    v_dbusernames VARCHAR(1000) := :'DBUSERNAMES';
    v_username VARCHAR(100);
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

        -- Revoke all privileges on all tables in this database
        v_sql := 'REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "' || v_username || '"';
        EXECUTE v_sql;

        -- Revoke default privileges
        v_sql := 'ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM "' || v_username || '"';
        EXECUTE v_sql;

        RAISE NOTICE 'Privileges revoked for user: %', v_username;
    END LOOP;
END
$$;
