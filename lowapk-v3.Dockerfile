# syntax=docker/dockerfile:1


FROM ghcr.io/astral-sh/uv:latest AS distroless-uv
FROM cgr.dev/chainguard/python:latest-dev AS build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root:root
RUN apk update \
    && apk --no-progress --no-cache add \
        mimalloc2 \
        snmalloc \
    && apk --no-progress --no-cache upgrade \
    && rm -rf /var/cache/apk/*;

WORKDIR /emptydir/usr/lib/
RUN cp -a /usr/lib/libmimalloc-secure.so* \
          /usr/lib/libsnmalloc*.so \
          /emptydir/usr/lib/

COPY --link --from=distroless-uv /uv /uvx \
    /usr/local/bin/
ENV PATH="/home/nonroot/.local/bin:${PATH}" \
    UV_COMPILE_BYTECODE=1 \
    UV_NO_CACHE=1
USER nonroot:nonroot
WORKDIR /home/nonroot/
RUN uv --no-progress tool install \
        'https://static.saveweb.org/lowapk-3.0.0-py3-none-any.whl'


FROM cgr.dev/chainguard/python:latest
# be aware of the ownership of /home/nonroot/
# refer to: https://github.com/moby/buildkit/issues/4964
COPY --from=build                         /emptydir/     /
COPY --from=build --chown=nonroot:nonroot /home/nonroot/ /home/nonroot/
WORKDIR /home/nonroot/

ENV TZ=Asia/Taipei
ENV LD_PRELOAD=/usr/lib/libsnmallocshim-checks.so
ENTRYPOINT [ "/home/nonroot/.local/bin/lowapk" ]
