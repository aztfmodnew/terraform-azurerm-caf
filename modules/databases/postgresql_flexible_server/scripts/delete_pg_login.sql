-- Delete PostgreSQL login (server-level role)
-- Cleanup procedure on destroy

REASSIGN OWNED BY :'DBUSERNAMES' TO current_user;
DROP OWNED BY :'DBUSERNAMES';
DROP ROLE IF EXISTS :'DBUSERNAMES';
