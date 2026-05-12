#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

# Delete user from target database
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "${PGDATABASE}" -v DBUSERNAMES="${DBUSERNAMES}" -f "${SQLUSERFILEPATH}"

# Delete login from postgres database (server level)
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "postgres" -v DBUSERNAMES="${DBUSERNAMES}" -f "${SQLLOGINFILEPATH}"

echo "PostgreSQL user(s) deleted successfully"
