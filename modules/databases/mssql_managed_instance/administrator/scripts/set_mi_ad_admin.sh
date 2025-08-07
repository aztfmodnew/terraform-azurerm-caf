#!/bin/bash

set -e

echo "Assigning ${DISPLAY_NAME} as ${MI_NAME} admin"

# Validate that OBJECT_ID is not empty
if [ -z "${OBJECT_ID}" ]; then
	echo "Error: OBJECT_ID is empty. Cannot assign admin role."
	exit 1
fi

# Try to assign the administrator
if az sql mi ad-admin create -u "${DISPLAY_NAME}" --mi "${MI_NAME}" -i "${OBJECT_ID}" -g "${RG_NAME}"; then
	echo "${DISPLAY_NAME} assigned as ${MI_NAME} admin"
else
	echo "Failed to assign ${DISPLAY_NAME} as ${MI_NAME} admin"
	echo "This might be due to an empty Azure AD group or invalid object ID"
	exit 1
fi
