FROM quay.io/minio/minio:RELEASE.2025-05-24T17-08-30Z AS source
FROM ghcr.io/radiorabe/ubi9-minimal:0.9.1 AS app

COPY --from=source /usr/bin/minio /usr/bin/minio
COPY --from=source /usr/bin/mc /usr/bin/mc
COPY --from=source /usr/bin/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY --from=source /licenses /licenses/minio
COPY LICENSE /licenses/

ENV PATH=/opt/bin:$PATH

RUN    microdnf install -y epel-release \
    && microdnf install -y \
         shadow-utils \
         minisign \
    && useradd -u 1001 -r -g 0 -s /sbin/nologin \
         -c "Default Application User" default \
    && microdnf remove -y \
         libsemanage \
         shadow-utils \
    && microdnf clean all

EXPOSE 9000/tcp
USER 1001
VOLUME /data
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]
