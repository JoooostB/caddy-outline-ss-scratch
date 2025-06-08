FROM golang:1.24-alpine AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /opt/xcaddy
RUN apk add -q --progress --update --no-cache git ca-certificates tzdata \
    && go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
    && xcaddy build --with github.com/iamd3vil/caddy_yaml_adapter --with github.com/Jigsaw-Code/outline-ss-server/outlinecaddy

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

ENV HOME=/opt/xcaddy \
    CADDYPATH=/opt/xcaddy/data \
    TZ=Europe/Amsterdam
COPY --from=builder --chown=1000 /opt/xcaddy /opt/xcaddy
WORKDIR /opt/xcaddy

CMD ["./caddy", "run", "--config", "/opt/xcaddy/config.yaml", "--adapter", "yaml", "--watch"]