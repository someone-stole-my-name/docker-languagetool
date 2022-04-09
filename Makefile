
LANGUAGETOOL_VERSION := 5.7
TRIVY_VERSION := 0.24.2

BUILDARG_VERSION := --build-arg VERSION=$(LANGUAGETOOL_VERSION)
IMAGENAME := ghcr.io/someone-stole-my-name/docker-languagetool
BUILDARG_PLATFORM := --platform linux/amd64,linux/arm64/v8
DOCKER_EXTRA_ARGS := 

ci-deps:
	apt-get -qq -y install \
		binfmt-support \
		ca-certificates \
		curl \
		git \
		gnupg \
		lsb-release \
		qemu-user-static \
		wget \
		jq

ci-deps-docker:
	curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
	echo "deb [arch=$(shell dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(shell lsb_release -cs) stable" |\
	tee /etc/apt/sources.list.d/docker.list > /dev/null && \
	cat /etc/apt/sources.list.d/docker.list && \
	apt-get update && \
	apt-get -qq -y install \
		docker-ce \
		docker-ce-cli \
		containerd.io

ci-deps-trivy:
	wget https://github.com/aquasecurity/trivy/releases/download/v$(TRIVY_VERSION)/trivy_$(TRIVY_VERSION)_Linux-64bit.deb && \
	dpkg -i trivy_$(TRIVY_VERSION)_Linux-64bit.deb

ci-setup-buildx:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx create --name mybuilder
	docker buildx use mybuilder

ci-prepare: ci-deps ci-deps-docker ci-deps-trivy ci-setup-buildx

build: ci-prepare
	docker buildx build $(BUILDARG_VERSION) $(BUILDARG_PLATFORM) -t $(IMAGENAME):latest .
	docker buildx build $(BUILDARG_VERSION) --load -t $(IMAGENAME):latest .

push: ci-prepare
	docker buildx build $(BUILDARG_VERSION) $(BUILDARG_PLATFORM) -t $(IMAGENAME):latest . --push
	docker buildx build $(BUILDARG_VERSION) $(BUILDARG_PLATFORM) -t $(IMAGENAME):$(shell git describe --tags --abbrev=0) . --push

trivy:
	trivy i \
		--ignore-unfixed \
		--exit-code 1 \
		$(IMAGENAME):latest

test: build test-int

test-int-start:
	docker kill languagetool || true
	docker rm languagetool || true
	docker run --rm -d --name languagetool -p 8010:8010 $(IMAGENAME):latest

test-int-run: IP=$(subst ",,$(shell docker inspect languagetool | jq '.[0].NetworkSettings.IPAddress'))
test-int-run:
	timeout 60 sh -c 'until (curl -i $(IP):8010/v2/info | grep "200 OK") do sleep 1; done'
	curl \
		-X GET \
		--header 'Accept: application/json' \
		--fail \
		'http://$(IP):8010/v2/languages'
	curl \
		-X POST \
		--header 'Content-Type: application/x-www-form-urlencoded' \
		--header 'Accept: application/json' \
		--fail \
		-d 'text=hello%20woorld&language=en-US&motherTongue=de-DE&enabledOnly=false' \
		'http://$(IP):8010/v2/check'


test-int: test-int-start test-int-run

docker-%:
	docker run \
		--rm \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd):/data \
		-w /data $(DOCKER_EXTRA_ARGS) \
		debian:stable sh -c "apt-get update && apt-get install make && make $*"
