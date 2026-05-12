#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

echo "Deleting PostgreSQL user: ${DBUSERNAMES}"

# Revoke privileges on target database
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "${PGDATABASE}" \
  -c "REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM \"${DBUSERNAMES}\""

# Revoke default privileges on target database
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "${PGDATABASE}" \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM \"${DBUSERNAMES}\""

# Reassign and drop owned objects on postgres database (server level)
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "postgres" \
  -c "REASSIGN OWNED BY \"${DBUSERNAMES}\" TO current_user"

psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "postgres" \
  -c "DROP OWNED BY \"${DBUSERNAMES}\""

# Drop the login/role
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "postgres" \
  -c "DROP ROLE IF EXISTS \"${DBUSERNAMES}\""

echo "PostgreSQL user deleted successfully"
