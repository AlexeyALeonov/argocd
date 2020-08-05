FROM argoproj/argocd:latest as build
USER root
RUN git clone https://github.com/kubernetes-sigs/kustomize.git
RUN apt update && apt install -y wget
RUN wget https://golang.org/dl/go1.14.6.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.14.6.linux-amd64.tar.gz && \
    rm go1.14.6.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin && cd kustomize/kustomize && go install .

FROM bitnami/minideb
# RUN apk --no-cache add ca-certificates musl
COPY --from=build /root/go/bin/kustomize /usr/local/bin/kustomize
