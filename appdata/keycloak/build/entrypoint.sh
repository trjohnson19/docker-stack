#!/bin/bash
# Inspired by https://github.com/keycloak/keycloak/issues/10816#issue-1173415169

# Read secrets
# shellcheck source=/dev/null
source /build/docker_secrets.sh

# Pass all command parameters
exec /opt/keycloak/bin/kc.sh "$@"
