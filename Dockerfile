ARG PROM_IMAGE
FROM ${PROM_IMAGE} as PROMETHEUS

FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4-200.1622548483

COPY --from=PROMETHEUS /bin/prometheus                             /bin/prometheus
COPY --from=PROMETHEUS /bin/promtool                               /bin/promtool
COPY --from=PROMETHEUS /etc/prometheus/prometheus.yml              /etc/prometheus/prometheus.yml
COPY --from=PROMETHEUS /usr/share/prometheus/console_libraries/    /usr/share/prometheus/console_libraries/
COPY --from=PROMETHEUS /usr/share/prometheus/consoles/             /usr/share/prometheus/consoles/
COPY --from=PROMETHEUS /LICENSE/                                   /licenses/
COPY --from=PROMETHEUS /NOTICE                                     /NOTICE
COPY --from=PROMETHEUS /npm_licenses.tar.bz2                       /npm_licenses.tar.bz2

RUN ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/
RUN mkdir -p /prometheus && \
    chown -R nobody etc/prometheus /prometheus

RUN microdnf update openssl-libs
RUN  microdnf install yum && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical && \
    microdnf remove yum && \
    microdnf clean all

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus

ARG PROM_IMAGE
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>" \
        name="prometheus" \
        vendor="https://github.com/prometheus/prometheus" \
        version="${PROM_IMAGE}" \
        release="${PROM_IMAGE}" \
        summary="Prometheus image with red hat UBI as base image" \
        description="Prometheus image with red hat UBI as base image"

ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
