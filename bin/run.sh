#!/usr/bin/env bash
set -eux
BASENAME=$(basename -s .sh "$0")
ARRAY=(${BASENAME//-/ })
echo "# = ${#ARRAY[@]}"

if [ ${#ARRAY[@]} -lt 3 ]; then
    echo "name pattern not followed:  <NAME>-<DOMAIN>-<STAGE>(-<VARIANT>)"
    exit 1
fi

CONFIG_NAME=${ARRAY[0]}
CONFIG_DOMAIN=${ARRAY[1]}
CONFIG_STAGE=${ARRAY[2]}
CONFIG_PATH=$CONFIG_DOMAIN/$CONFIG_STAGE
VARIABLES=()
VARIABLES+=(-e)
VARIABLES+=(config_domain=$CONFIG_DOMAIN)
VARIABLES+=(-e)
VARIABLES+=(config_stage=$CONFIG_STAGE)

if [ ${#ARRAY[@]} -gt 3 ]; then
   CONFIG_VARIANT=${ARRAY[3]}
   CONFIG_PATH=$CONFIG_PATH/$CONFIG_VARIANT
   VARIABLES+=(-e)
   VARIABLES+=(config_variant=$CONFIG_STAGE)
fi

TARGET=playbook.yaml

[[ "${ARRAY[0]}" == run  ]] && ACTION=ansible-playbook
[[ "${ARRAY[0]}" == test ]] && ACTION=ansible-inventory TARGET=--list

LIST=($(cat<<EOF
inventory/$CONFIG_PATH
EOF
))

ITEMS=()
for FILEPATH in "${LIST[@]}"; do
        if [ ! -e "${FILEPATH}" ]; then
                echo "$FILEPATH not found." >&2
                exit 1
        else
                ITEMS+=(-i)
                ITEMS+=(${FILEPATH})
        fi
done

$ACTION \
  ${ITEMS[@]} \
  ${VARIABLES[@]} \
  "${TARGET}" \
  "$@"
