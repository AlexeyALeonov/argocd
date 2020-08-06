FROM golang:1.14 as build
RUN git clone https://github.com/kubernetes-sigs/kustomize.git
RUN cd kustomize/kustomize && go install .

FROM bitnami/minideb
COPY --from=build /go/bin/kustomize /usr/local/bin/kustomize
