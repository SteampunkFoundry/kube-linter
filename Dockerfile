FROM stackrox/kube-linter:0.2.0 AS original

FROM busybox:1.32.1-uclibc
COPY --from=original /kube-linter /

CMD ["/kube-linter"]
