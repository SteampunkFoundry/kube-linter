FROM stackrox/kube-linter:0.1.4 AS original

FROM busybox:1.32.0-uclibc
COPY --from=original /kube-linter /

CMD ["/kube-linter"]
