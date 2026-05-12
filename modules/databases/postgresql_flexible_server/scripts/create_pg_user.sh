#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

# Create login on postgres database (server level)
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "postgres" -v DBUSERNAMES="${DBUSERNAMES}" -v DBUSERPASSWORDS="${DBUSERPASSWORDS}" -f "${SQLLOGINFILEPATH}"

# Create user and assign role on target database
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "${PGDATABASE}" -v DBUSERNAMES="${DBUSERNAMES}" -v DBROLES="${DBROLES}" -f "${SQLUSERFILEPATH}"

echo "PostgreSQL user(s) created successfully"
