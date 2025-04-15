#!/bin/bash

set -e
echo "[SQLSERVER]
Driver = ODBC Driver 17 for SQL Server
Server = tcp:${SQLCMDSERVER},1433
Authentication = ActiveDirectoryDefault" | sudo tee /etc/odbc.ini > /dev/null

# Use environment variables for connection details
sqlcmd -v DBUSERNAMES="${DBUSERNAMES}" DBROLES="${DBROLES}" -S SQLSERVER -d "${SQLCMDDBNAME}" -i "${SQLFILEPATH}" -D -G
#sqlcmd -v DBUSERNAMES="${DBUSERNAMES}" DBROLES="${DBROLES}" -S SQLSERVER -d "${SQLCMDDBNAME}" -i "${SQLFILEPATH}" -D