#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

# Set database permissions for users/groups/managed identities
psql -h "${PGHOST}" -p "${PGPORT}" -U "${DBADMINUSER}" -d "${PGDATABASE}" -v DBUSERNAMES="${DBUSERNAMES}" -v DBROLES="${DBROLES}" -f "${SQLFILEPATH}"

echo "PostgreSQL database permissions set successfully"
