# Environment options:
# BUILD_OPTS -- useful for --no-cache and similar

all: go-server go-agent

go-server:
	docker build $(BUILD_OPTS) -f Dockerfile.gocd-server -t platformr/gocd-server .

go-agent:
	docker build $(BUILD_OPTS) -f Dockerfile.gocd-agent -t platformr/gocd-agent .

key:
	ssh-keygen -b 4096 -t rsa -N '' -f ssh/id_rsa

@phony: all