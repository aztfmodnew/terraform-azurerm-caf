#!/bin/bash
set -e

export PGPASSWORD="${DBADMINPWD}"
export PGSSLMODE="require"

# Strip surrounding single quotes added by Terraform format("'%s'", ...)
CLEANED_USERNAMES=$(echo "${DBUSERNAMES}" | sed "s/^'//;s/'$//")
CLEANED_ROLES=$(echo "${DBROLES}" | sed "s/^'//;s/'$//")

echo "Setting database permissions for users: ${CLEANED_USERNAMES}"
echo "Roles to assign: ${CLEANED_ROLES}"

PSQL_CMD="psql -h ${PGHOST} -p ${PGPORT} -U ${DBADMINUSER} -d ${PGDATABASE}"

# Split comma-separated usernames and roles
IFS=',' read -ra USERS <<< "${CLEANED_USERNAMES}"
IFS=',' read -ra ROLES <<< "${CLEANED_ROLES}"

for USERNAME in "${USERS[@]}"; do
  USERNAME=$(echo "${USERNAME}" | xargs)  # trim whitespace
  echo "Processing user: ${USERNAME}"

  # Create role if it doesn't exist
  ${PSQL_CMD} -c "
    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${USERNAME}') THEN
        CREATE ROLE \"${USERNAME}\" WITH LOGIN;
        RAISE NOTICE 'Role created: ${USERNAME}';
      ELSE
        RAISE NOTICE 'Role already exists: ${USERNAME}';
      END IF;
    END
    \$\$;
  "

  # Grant each role to the user
  for ROLE in "${ROLES[@]}"; do
    ROLE=$(echo "${ROLE}" | xargs)  # trim whitespace
    echo "Granting role ${ROLE} to ${USERNAME}"
    ${PSQL_CMD} -c "GRANT \"${ROLE}\" TO \"${USERNAME}\";"
  done
done

echo "PostgreSQL database permissions set successfully"
