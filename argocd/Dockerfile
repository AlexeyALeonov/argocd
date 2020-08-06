FROM golang:1.14 as build
RUN GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3

FROM bitnami/minideb
COPY --from=build /go/bin/kustomize /usr/local/bin/kustomize
