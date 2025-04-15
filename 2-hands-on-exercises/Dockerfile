FROM golang:1.20

WORKDIR /app

COPY . .

# Tell golang to produce a static binary, this is more relevant is we do multi-stage container builds
ENV CGO_ENABLED=0 GOOS=linux 

RUN go mod init myapp || echo "go.mod already exists"

RUN go mod tidy

RUN go build -o hello-app .

EXPOSE 8080

CMD ["./hello-app"]
# ENTRYPOINT ["./hello-app"]