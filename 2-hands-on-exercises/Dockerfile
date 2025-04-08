FROM golang:1.20

WORKDIR /app

COPY . .

RUN go mod init myapp || echo "go.mod already exists"

RUN go mod tidy

RUN go build -o hello-app .


EXPOSE 8080


CMD ["./hello-app"]
# ENTRYPOINT ["./hello-app"]