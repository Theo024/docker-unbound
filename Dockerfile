FROM alpine:latest as build

RUN apk add --no-cache build-base openssl-dev expat-dev && \
    wget -O - https://nlnetlabs.nl/downloads/unbound/unbound-1.12.0.tar.gz | tar xz && \
    cd unbound-1.12.0 && \
    ./configure --prefix=/unbound && \
    make && \
    make install


FROM alpine:latest

COPY --from=build /unbound /unbound

RUN apk add --no-cache openssl expat && \
    addgroup -S unbound && \
    adduser -D -H -S -h /unbound -g "unbound" -s /sbin/nologin -G unbound unbound && \
    chown -R unbound unbound

CMD ["/unbound/sbin/unbound", "-dd", "-c", "/unbound/etc/unbound/unbound.conf"]
