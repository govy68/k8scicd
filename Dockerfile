FROM golang:alpine AS build-env
RUN mkdir /go/src/app && apk update && apk add git
ADD main.go /go/src/app/
WORKDIR /go/src/app
#RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .
#RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -mod=vendor -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .
#RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-s' -o app .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main main.go

FROM scratch
WORKDIR /app
#COPY --from=build-env /go/src/app/app .
COPY --from=build-env /go/src/app .
ENTRYPOINT [ "./app" ]
