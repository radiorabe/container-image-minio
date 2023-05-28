FROM quay.io/minio/minio:RELEASE.2023-05-18T00-05-36Z AS source
FROM ghcr.io/radiorabe/ubi9-minimal:0.4.0 AS app

COPY --from=source /opt /opt
COPY --from=source /usr/bin/verify-minio.sh /usr/bin/verify-minio.sh
COPY --from=source /usr/bin/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY --from=source /licenses /licenses/minio
COPY LICENSE /licenses/

ENV PATH=/opt/bin:$PATH

RUN    curl -L -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && rpm -ivh ./epel-release-*.noarch.rpm \
    && rm ./epel-release-*.noarch.rpm \
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
