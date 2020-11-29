#!/usr/bin/env sh
${VERBOSE} && set -x

# shellcheck source=/dev/null
test -f "${HOOKS_DIR}/pingcommon.lib.sh" && . "${HOOKS_DIR}/pingcommon.lib.sh"

#
# Wait for PingDataSync (localhost) before continuing
#
echo "Waiting for PingDataSync - 127.0.0.1:${LDAPS_PORT}..."
wait-for "127.0.0.1:${LDAPS_PORT}" || exit 1
echo "127.0.0.1:${LDAPS_PORT} appears available"

#
# Wait for PingDirectory before continuing
#
echo "Waiting for PingDirectory - ${PD_ENGINE_PRIVATE_HOSTNAME}:${LDAPS_PORT}..."
wait-for "${PD_ENGINE_PRIVATE_HOSTNAME}:${LDAPS_PORT}" || exit 1
echo "${PD_ENGINE_PRIVATE_HOSTNAME}:${LDAPS_PORT} appears available"
sleep 2

#
# Set the sync pipe at the beginning of the changelog
#
realtime-sync set-startpoint \
    --end-of-changelog \
    --pipe-name pingdirectory_source-to-pingdirectory_destination

#
# Enable the sync pipe
#
dsconfig set-sync-pipe-prop \
    --pipe-name pingdirectory_source-to-pingdirectory_destination  \
    --set started:true \
    --no-prompt