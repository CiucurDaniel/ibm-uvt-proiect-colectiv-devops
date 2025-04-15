# Hands on exercises

![Cat with keyboard](../_img/tuto-docker.png "Let's create some containers")

## Install Podman (Rokcylinux)

Podman should come pre-installed in Rockylinux. If that is not the case, install it using:

```bash
dnf install podman
```

Verify installation: 

```bash
podman version
```

> Hint: [Rockylinux - Podman Guide](https://docs.rockylinux.org/guides/containers/podman_guide/)
[Rockylinux - Podman Guide - 2](https://docs.rockylinux.org/gemstones/containers/podman/)

## Create an account on Dockerhub.com

Go to https://hub.docker.com and sign up for an account. 

**Remember the credentials!** We will need them to push images to DockerHub

## Pull an image from a public container registry

```bash
# Pull an ubuntu image
podman pull docker.io/ubuntu:22.04

# list local images
podman image list

# Run your first container
podman run --rm ubuntu:22.04 cat /etc/os-release

# Run container interactively
podman run -it --name my-container ubuntu:22.04

# (inside container) install git
apt-get update && apt-get install -y git
```

>HINT: Always use `--help` to know various flags you can use. Like --rm flag on podman run which "Automatically removes the container and its associated anonymous volumes when it exits"

## Make changes to an images and save it

```bash
# Run container interactively
# -i flag -> Keeps STDIN (standard input) open, even if not attached
# -t flag -> Allocates a pseudo-TTY (a terminal). Makes the container look and feel like a real terminal session.
podman run -it --name my-container ubuntu:22.04

# From inside ubuntu container install git
apt-get update && apt-get install -y git

# Commit your changes in a new container
podman commit my-container my-ubuntu-with-git

# Now enter you container and check is git is is installed
podman run -it my-ubuntu-with-git

git version
```

>HINT: You will almost never do this. You always create a `Containerfile` such that all dependencies can be tracked effectively.

## Build and tag an image

Create a directory and save the code bellow in a file called `main.go`.

```bash
cd 
mkdir app && cd app
vi main.go # paste snipped from bellow
```

```go
package main

import (
	"fmt"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello, world!")
}

func main() {
	http.HandleFunc("/hello", helloHandler)
	fmt.Println("Server is running on http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
```

Next create a Containerfile

```bash
vi Containerfile
```

```Dockerfile
FROM docker.io/golang:1.20

WORKDIR /app

COPY . .

RUN go mod init myapp || echo "go.mod already exists"

RUN go mod tidy

RUN go build -o hello-app .

EXPOSE 8080

CMD ["./hello-app"]
# ENTRYPOINT ["./hello-app"]
```

```bash
podman build -t go-hello-app .

podman run -d -p 8080:8080 go-hello-app

curl http://localhost:8080 # you need to install curl on rockylinux via: dnf install curl

podman stop <generated_name_for_container>
```

>HINT: Use `podman build --help` to check for important flags. In this case we are interested to gie the image a name and tag which is done via  `-t, --tag Name and optionally a tag (format: "name:tag")` flag.     

>HINT: Port forwarding in Docker/Podman allows you to map a port on your local machine to a port inside the container, enabling you to access the container’s services from outside.

>HINT: The `-d` flag ensures that the container runs in detached mode, so your terminal remains free for other commands.

## Push an image to a public container registry

```bash
podman login docker.io

podman image ls

podman tag go-hello-app docker.io/ciucurdaniel/go-hello-app:latest

podman push docker.io/ciucurdaniel/go-hello-app:latest
```

Go to container registry and check your image will now exist within a repository.

Example: https://hub.docker.com/r/ciucurdaniel/go-hello-app

## Multi-stage container builds

First we create a seprate folder where we copy the golang code and the Dockerfile

```bash
cd
ls # should show the app/ directory with main.go and Dockerfile inside
mkdir multi-stage-app
cp app/* /multi-stage-app
```

```Dockerfile
# This will be stage 1 the build stage
FROM golang:1.20 as builder 

WORKDIR /app

COPY . .

# Tell golang to produce a static binary, this is more relevant is we do multi-stage container builds
ENV CGO_ENABLED=0 GOOS=linux 

RUN go mod init myapp || echo "go.mod already exists"

RUN go mod tidy

RUN go build -o hello-app .

# This will be the second stage where we have a very minimal base image and we just add our binary
FROM scratch

COPY --from=builder /app/hello-app /app/hello-app

EXPOSE 8080

CMD ["/app/hello-app"]
# ENTRYPOINT ["./hello-app"]
```

```bash
# Build the image
podman build -t test-multi-stage .

# Run the image just to confirm it works correctly 
podman run -d -p 8080:8080 test-multi-stage

curl http://localhost:8080
```

Compare the image sizes

```bash
podman images
```

The image build in a single stage which still contains the GO SDK will have around `943 MB` while the image build using multiple stages will have only about `6.24 MB`.