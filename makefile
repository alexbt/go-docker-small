.VERSION:=1.0.0
.BRANCH:=`git branch | grep \* | cut -d ' ' -f2`
.GIT_HASH:=`git rev-parse --short HEAD`
.TIMESTAMP:=`date +%FT%T%z`
.LDFLAGS:=""
.BIN_NAME:=`basename cmd/*`
.PROJECT_NAME:=`basename "$(CURDIR)"`
.BUILD_IMAGE_TAG:=go_build_${.PROJECT_NAME}_${.GIT_HASH}
.RT_IMAGE_TAG:=${.BRANCH}-${.VERSION}-${.GIT_HASH}

docker-build:
	docker build -t ${.BUILD_IMAGE_TAG} --build-arg project_name=${.PROJECT_NAME} -f Dockerfile_build .
	docker run ${.BUILD_IMAGE_TAG} cat /go/bin/${.BIN_NAME} > ${.BIN_NAME}
	docker rmi -f ${.BUILD_IMAGE_TAG}
	docker build -t ${.PROJECT_NAME}:${.RT_IMAGE_TAG} --build-arg bin_name=${.BIN_NAME} -f Dockerfile_runtime .
	rm -f ./${.BIN_NAME}

run:
	docker run -p 8081:8080 -it ${.PROJECT_NAME}:${.RT_IMAGE_TAG}

all:
	${MAKE} getdeps
	${MAKE} clean
	govendor install -a ./...
	${MAKE} test

install:
	${MAKE} all

build:
	${MAKE} getdeps
	${MAKE} clean
	govendor build ${.LDFLAGS} ./...
	${MAKE} test

vendor:
	go get -u github.com/kardianos/govendor
	govendor sync
	govendor update

getdeps:
	go get -u github.com/kardianos/govendor
	go get -d -t ./...

test:
	govendor test -parallel 10 -cover ./...

clean:
	govendor clean
