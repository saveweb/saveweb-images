# syntax=docker/dockerfile:1


FROM cgr.dev/chainguard/python:latest-dev AS build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root:root
RUN apk update \
    && apk --no-progress --no-cache add \
        curl \
        jemalloc \
        mimalloc2 \
        snmalloc \
    && apk --no-progress --no-cache upgrade \
    && rm -rf /var/cache/apk/*;

WORKDIR /emptydir/usr/lib/
RUN cp -a /usr/lib/libjemalloc.so.2 \
          /usr/lib/libmimalloc-secure.so* \
          /usr/lib/libsnmalloc*.so \
          /emptydir/usr/lib/

USER nonroot:nonroot
WORKDIR /home/nonroot/
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN source /home/nonroot/.cargo/env \
    && uv venv \
    && source /home/nonroot/.venv/bin/activate \
    && uv pip --no-cache-dir install --upgrade \
        https://static.saveweb.org/lowapk_v2-2.0.3-py3-none-any.whl

RUN echo 'source /home/nonroot/.cargo/env' > /home/nonroot/.bashrc \
    && echo 'source /home/nonroot/.venv/bin/activate' >> /home/nonroot/.bashrc \
    && chmod +x /home/nonroot/.bashrc \
                /home/nonroot/.cargo/env \
                /home/nonroot/.venv/bin/activate \
                /home/nonroot/.venv/bin/lowapk_v2;


FROM cgr.dev/chainguard/python:latest AS assets
# be aware of the ownership of /home/nonroot/
# refer to: https://github.com/moby/buildkit/issues/4964
COPY --from=build                         /emptydir/     /emptydir/
COPY --from=build --chown=nonroot:nonroot /home/nonroot/ /emptydir/home/nonroot/


FROM cgr.dev/chainguard/python:latest
COPY --link --from=assets /emptydir/ /
WORKDIR /home/nonroot/

ENV TZ=Asia/Taipei
ENV VIRTUAL_ENV=/home/nonroot/.venv
ENV PATH="${VIRTUAL_ENV}/bin:/home/nonroot/.cargo/bin:${PATH}"
ENV LD_PRELOAD=/usr/lib/libsnmallocshim-checks.so

ENTRYPOINT [ "python3" ]
CMD [ "/home/nonroot/.venv/bin/lowapk_v2" ]
