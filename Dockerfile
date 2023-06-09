FROM quay.io/minio/minio:RELEASE.2023-07-07T07-13-57Z AS source
FROM ghcr.io/radiorabe/ubi9-minimal:0.4.1 AS app

COPY --from=source /opt /opt
COPY --from=source /usr/bin/verify-minio.sh /usr/bin/verify-minio.sh
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
    && /usr/bin/verify-minio.sh \
    && microdnf clean all

EXPOSE 9000/tcp
USER 1001
VOLUME /data
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]
