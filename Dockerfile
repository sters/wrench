FROM golang:1.24 as build

ARG VERSION

WORKDIR /go/src/app
COPY . .

RUN --mount=type=cache,target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,target=/root/.cache/go-build,sharing=locked \
    --mount=type=bind,source=go.mod,target=go.mod \
    --mount=type=bind,source=go.sum,target=go.sum \
    go mod download

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=bind,source=.,target=. \
    CGO_ENABLED=0 \
    go build \
    -ldflags "-s -w -X github.com/cloudspannerecosystem/wrench/cmd.version=${VERSION}" \
    -o /go/bin/app/wrench

FROM gcr.io/distroless/static-debian12
COPY --from=build /go/bin/app/wrench /
ENTRYPOINT ["/wrench"]
