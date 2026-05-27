#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

# Strip surrounding single quotes added by Terraform
CLEANED_USERNAMES=$(echo "${DBUSERNAMES}" | sed "s/^'//;s/'$//")

echo "Revoking database permissions for users: ${CLEANED_USERNAMES}"

PSQL_DBNAME="psql -h ${PGHOST} -p ${PGPORT} -U ${DBADMINUSER} -d ${PGDATABASE}"

# Split comma-separated usernames
IFS=',' read -ra USERS <<< "${CLEANED_USERNAMES}"

for USERNAME in "${USERS[@]}"; do
  USERNAME=$(echo "${USERNAME}" | xargs)  # trim whitespace
  echo "Revoking permissions for user: ${USERNAME}"

  # Drop owned objects
  ${PSQL_DBNAME} -c "DROP OWNED BY \"${USERNAME}\";" 2>/dev/null || true

  # Drop the role if it exists
  ${PSQL_DBNAME} -c "DROP ROLE IF EXISTS \"${USERNAME}\";" 2>/dev/null || true
done

echo "Database permissions revoked successfully"
