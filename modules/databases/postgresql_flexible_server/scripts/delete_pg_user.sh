#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

echo "Deleting PostgreSQL user: ${DBUSERNAMES}"

PSQL_POSTGRES="psql -h ${PGHOST} -p ${PGPORT} -U ${DBADMINUSER} -d postgres"
PSQL_DBNAME="psql -h ${PGHOST} -p ${PGPORT} -U ${DBADMINUSER} -d ${PGDATABASE}"

# Drop owned objects in the target database (handles grants, default privileges, etc.)
${PSQL_DBNAME} -c "DROP OWNED BY \"${DBUSERNAMES}\";" || true

# Drop owned objects in postgres database (server-level)
${PSQL_POSTGRES} -c "DROP OWNED BY \"${DBUSERNAMES}\";" || true

# Drop the role
${PSQL_POSTGRES} -c "DROP ROLE IF EXISTS \"${DBUSERNAMES}\";"

echo "PostgreSQL user deleted successfully"
