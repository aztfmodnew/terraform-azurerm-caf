-- Delete PostgreSQL login (server-level role)

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

        -- Check if login exists and delete it
        IF EXISTS (SELECT 1 FROM pg_catalog.pg_user WHERE usename = v_username) THEN
            -- Reassign owned objects if needed
            v_sql := 'REASSIGN OWNED BY "' || v_username || '" TO current_user';
            EXECUTE v_sql;
            
            -- Drop owned objects
            v_sql := 'DROP OWNED BY "' || v_username || '"';
            EXECUTE v_sql;
            
            -- Drop the login
            v_sql := 'DROP ROLE IF EXISTS "' || v_username || '"';
            EXECUTE v_sql;
            RAISE NOTICE 'Login deleted: %', v_username;
        ELSE
            RAISE NOTICE 'Login does not exist: %', v_username;
        END IF;
    END LOOP;
END
$$;
