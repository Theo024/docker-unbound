FROM alpine:latest as build

RUN apk add --no-cache build-base openssl-dev expat-dev nghttp2-dev && \
    wget -O - https://nlnetlabs.nl/downloads/unbound/unbound-1.12.0.tar.gz | tar xz && \
    cd unbound-1.12.0 && \
    ./configure --prefix=/unbound --with-libnghttp2 && \
    make && \
    make install


FROM alpine:latest

COPY --from=build /unbound /unbound

RUN apk add --no-cache openssl expat nghttp2-libs && \
    addgroup -g 500 -S unbound && \
    adduser -u 500 -D -H -S -h /unbound -g "unbound" -s /sbin/nologin -G unbound unbound && \
    chown -R unbound:unbound /unbound

USER unbound

CMD ["/unbound/sbin/unbound", "-dd", "-c", "/unbound/etc/unbound/unbound.conf"]
