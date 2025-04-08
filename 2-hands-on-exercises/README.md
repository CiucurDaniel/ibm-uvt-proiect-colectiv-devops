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

# Run your first container
docker run --rm ubuntu:22.04 cat /etc/os-release

# Run container interactively
docker run -it --name my-container ubuntu:22.04

apt-get update && apt-get install -y git
```

>HINT: Always use `--help` to know various flags you can use. Like --rm flag on docker run which "Automatically removes the container and its associated anonymous volumes when it exits"

## Make changes to an images and save it

```bash
# Run container interactively
# -i flag -> Keeps STDIN (standard input) open, even if not attached
# -t flag -> Allocates a pseudo-TTY (a terminal). Makes the container look and feel like a real terminal session.
docker run -it --name my-container ubuntu:22.04

# From inside ubuntu container install git
apt-get update && apt-get install -y git

# Commit your changes in a new container
docker commit my-container my-ubuntu-with-git

# Now enter you container and check is git is is installed
docker run -it my-ubuntu-with-git

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
FROM golang:1.20

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
docker build -t go-hello-app .

docker run -d -p 8080:8080 go-hello-app

curl http://localhost:8080 # may need to install curl on rockylinux
```

>HINT: Use `docker build --help` to check for important flags. In this case we are interested to gie the image a name and tag which is done via  `-t, --tag Name and optionally a tag (format: "name:tag")` flag.     

>HINT: Port forwarding in Docker/Podman allows you to map a port on your local machine to a port inside the container, enabling you to access the container’s services from outside.

>HINT: The `-d` flag ensures that the container runs in detached mode, so your terminal remains free for other commands.

## Push an image to a public container registry

```bash
docker login docker.io

docker tag <a> <ab>

docker push 
```

Go to container registry and check your image will now exist within a repository.