FROM golang:1.20-alpine as builder
RUN mkdir -p /linode
WORKDIR /linode

COPY go.mod .
COPY go.sum .
COPY main.go .
COPY cloud ./cloud
COPY sentry ./sentry

RUN go mod download
RUN go build -a -ldflags '-extldflags "-static"' -o /bin/linode-cloud-controller-manager-linux /linode

FROM alpine:3.18.4
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
LABEL maintainers="Linode"
LABEL description="Linode Cloud Controller Manager"
COPY --from=builder /bin/linode-cloud-controller-manager-linux /linode-cloud-controller-manager-linux
ENTRYPOINT ["/linode-cloud-controller-manager-linux"]
