#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

echo "Creating PostgreSQL user: ${DBUSERNAMES}"

# Create login on postgres database (server level)
# Use -c to execute commands directly with proper escaping
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "postgres" \
  -c "CREATE ROLE \"${DBUSERNAMES}\" WITH LOGIN PASSWORD '$( echo "${DBUSERPASSWORDS}" | sed "s/'/''/g" )'"

# Create user and assign role on target database
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "${PGDATABASE}" \
  -c "GRANT \"${DBROLES}\" TO \"${DBUSERNAMES}\""

echo "PostgreSQL user created successfully"
