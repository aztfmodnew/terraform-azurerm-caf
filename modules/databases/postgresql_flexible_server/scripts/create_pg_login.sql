-- Create PostgreSQL login (server-level role)
-- Split comma-separated usernames and passwords

DO $$
DECLARE
    v_dbusernames VARCHAR(1000) := :'DBUSERNAMES';
    v_dbuserpasswords VARCHAR(2000) := :'DBUSERPASSWORDS';
    v_username VARCHAR(100);
    v_userpwd VARCHAR(500);
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

        -- Extract first password
        IF POSITION(',' IN v_dbuserpasswords) > 0 THEN
            v_userpwd := SUBSTRING(v_dbuserpasswords FROM 1 FOR POSITION(',' IN v_dbuserpasswords) - 1);
            v_dbuserpasswords := SUBSTRING(v_dbuserpasswords FROM POSITION(',' IN v_dbuserpasswords) + 1);
        ELSE
            v_userpwd := v_dbuserpasswords;
            v_dbuserpasswords := '';
        END IF;

        v_username := TRIM(v_username);

        -- Check if login already exists
        IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_user WHERE usename = v_username) THEN
            v_sql := 'CREATE ROLE "' || v_username || '" WITH LOGIN PASSWORD ' || quote_literal(v_userpwd);
            EXECUTE v_sql;
            RAISE NOTICE 'Login created: %', v_username;
        ELSE
            RAISE NOTICE 'Login already exists: %', v_username;
        END IF;
    END LOOP;
END
$$;
