FROM opensuse/tumbleweed:latest AS grafana

ARG GRAFANA_VERSION
ARG RELEASE_VERSION
ARG MEND_EMAIL
ARG MEND_URL
ARG MEND_USER_KEY
RUN mkdir -p /tmp/grafana-src && \
    mkdir -p /tmp/grafana-bin && \
    curl -L https://github.com/grafana/grafana/archive/refs/tags/v$GRAFANA_VERSION.tar.gz | tar --directory /tmp/grafana-src --strip-components 1 -zxvf - && \
    curl -L https://downloads.mend.io/cli/linux_amd64/mend -o /tmp/mend && chmod +x /tmp/mend && \
    /tmp/mend dep --dir /tmp/grafana-src --extended -s "OpenScape UC Portfolio//OSEM third party applications//grafana-osem-sourcecode - $GRAFANA_VERSION-r$RELEASE_VERSION" -u && \
    curl -L https://dl.grafana.com/oss/release/grafana-$GRAFANA_VERSION.linux-$(uname -p | sed s/aarch64/arm64/ | sed s/x86_64/amd64/).tar.gz | tar --directory /tmp/grafana-bin --strip-components 1 -zxvf -

FROM opensuse/tumbleweed:latest AS base

ARG GRAFANA_VERSION
RUN mkdir -p /etc/grafana && \
    mkdir -p /opt/grafana/{logs,data} && \
    mkdir -p /opt/grafana/data/plugins && \
    groupadd -g 3000 -r grafana && useradd -u 3000 -d /tmp -g grafana grafana && \
    rpm -e --allmatches $(rpm -qa --qf "%{NAME}\n" | grep -v -E "bash|coreutils|filesystem|glibc$|libacl1|libattr1|libcap2|libgcc_s1|libgmp|libncurses|libpcre1|libreadline|libselinux|libstdc\+\+|openSUSE-release|system-user-root|terminfo-base|libpcre2") && \
    rm -Rf /etc/zypp && \
    rm -Rf /usr/lib/zypp* && \
    rm -Rf /var/{cache,log,run}/* && \
    rm -Rf /var/lib/zypp && \
    rm -Rf /usr/lib/rpm && \
    rm -Rf /usr/lib/sysimage/rpm && \
    rm -Rf /usr/share/man && \
    rm -Rf /usr/local && \
    rm -Rf /srv/www && \
    rm -Rf /tmp/*

COPY --from=grafana /tmp/grafana-bin/bin/grafana* /opt/grafana/bin/
COPY --from=grafana /tmp/grafana-bin/conf /opt/grafana/conf
COPY --from=grafana /tmp/grafana-bin/public /opt/grafana/public
COPY --from=grafana /tmp/grafana-bin/LICENSE /opt/grafana/LICENSE
COPY --from=grafana /tmp/grafana-bin/VERSION /opt/grafana/VERSION

RUN chown -R grafana:grafana /opt/grafana && \
    chown -R grafana:grafana /etc/grafana

COPY --chown=grafana:grafana --chmod=740 grafana.ini /etc/grafana/grafana.ini
COPY --chown=grafana:grafana --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh

FROM scratch

COPY --from=base / /

USER 3000:3000

EXPOSE 3000

WORKDIR /opt/grafana

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD [ "/opt/grafana/bin/grafana", "server", "--homepath=/opt/grafana", "--config=/etc/grafana/grafana.ini", "--packaging=docker" ]
