ARG kube_linter_version=.0.2.0
FROM stackrox/kube-linter:${kube_linter_version} AS original

FROM busybox:1.32.1-uclibc
COPY --from=original /kube-linter /

HEALTHCHECK NONE
RUN adduser -Ds /bin/bash kubelinter
USER kubelinter

CMD ["/kube-linter"]
