# Install `curl` per https://www.keycloak.org/server/containers#_installing_additional_rpm_packages
FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs curl --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
    dnf --installroot /mnt/rootfs clean all && \
    rpm --root /mnt/rootfs -e --nodeps setup

# Copy build files to start files
FROM quay.io/keycloak/keycloak:23.0
COPY --from=ubi-micro-build /mnt/rootfs /

# Start keycloak
ENTRYPOINT ["/build/entrypoint.sh"]
