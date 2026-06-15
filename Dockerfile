FROM quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z@sha256:14cea493d9a34af32f524e538b8346cf79f3321eff8e708c1e2960462bd8936e AS source
FROM ghcr.io/radiorabe/ubi9-minimal:0.11.4@sha256:9d9f4695ed31b1856b258a1081abd15a99e1e62a7935b421a3c2e46bbdf62652 AS app

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
