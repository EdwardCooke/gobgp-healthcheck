FROM alpine AS build
WORKDIR /build

RUN apk add curl jq
RUN curl https://api.github.com/repos/osrg/gobgp/releases -o releases
RUN curl "$(jq -r '.[0] | .assets[] | select ( .name | test(".*_amd64.*")) | .browser_download_url' releases)" -L -o gobgp.tar.gz
RUN tar -xvzf gobgp.tar.gz
RUN rm releases && \
    rm gobgp.tar.gz && \
    rm LICENSE && \
    rm README.md
RUN chown root:root *
RUN ls

FROM alpine
RUN adduser -h /app -s /bin/false -S app
WORKDIR /app

ENV PATH=/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN apk add curl bash jq bind-tools

COPY --from=build /build/* /app

COPY startup.sh .
COPY configurator.sh .
COPY healthcheck.sh /config/healthcheck.sh
COPY initialize.sh /config/initialize.sh

USER app
ENTRYPOINT [ "./startup.sh" ]
