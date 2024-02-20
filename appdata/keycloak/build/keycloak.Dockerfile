# Keycloak can be rebuilt when changes are made to the Dockerfile using the `dcbuild2` from .bash_aliases
FROM quay.io/keycloak/keycloak:23.0 as builder

USER keycloak

# Build options
ARG ARG_KC_CACHE
# ARG ARG_KC_CACHE_CONFIG_FILE
# ARG ARG_KC_CACHE_STACK
ARG ARG_KC_DB
ARG ARG_KC_TRANSACTION_XA_ENABLED
ARG ARG_KC_FEATURES
# ARG ARG_KC_HTTP_RELATIVE_PATH
ARG ARG_KC_HEALTH_ENABLED
ARG ARG_KC_METRICS_ENABLED
# ARG ARG_KC_VAULT
# ARG ARG_KC_FIPS_MODE
ARG ARG_QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY

# Build ENV vars
ENV KC_CACHE "$ARG_KC_CACHE"
# ENV KC_CACHE_CONFIG_FILE "$ARG_KC_CACHE_CONFIG_FILE"
# ENV KC_CACHE_STACK "$ARG_KC_CACHE_STACK"
ENV KC_DB "$ARG_KC_DB"
ENV KC_TRANSACTION_XA_ENABLED "$ARG_KC_TRANSACTION_XA_ENABLED"
ENV KC_FEATURES "$ARG_KC_FEATURES"
# ENV KC_HTTP_RELATIVE_PATH "$ARG_KC_HTTP_RELATIVE_PATH"
ENV KC_HEALTH_ENABLED "$ARG_KC_HEALTH_ENABLED"
ENV KC_METRICS_ENABLED "$ARG_KC_METRICS_ENABLED"
# ENV KC_VAULT "$ARG_KC_VAULT"
# ENV KC_FIPS_MODE "$ARG_KC_FIPS_MODE"
ENV QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY "$ARG_QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY"

# First build keycloak
WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

# Copy build files to start files
FROM quay.io/keycloak/keycloak:23.0
COPY --from=builder /opt/keycloak/ /opt/keycloak/

USER keycloak

HEALTHCHECK \
    --interval=10s \
    --timeout=3s \
    --start-period=30s \
    --retries=3 \
    CMD /build/healthcheck.sh || exit 1

# Start keycloak with Docker secrets
ENTRYPOINT ["/build/entrypoint.sh"]
