-include .env # Applies to every target in the file!

#
## Standalone Docker Tasks
#
LOCAL_IP=$(shell ipconfig getifaddr en0)
docker-login:
	@if [ "${DOCKER_ECR}" != "" ]; then \
		aws-vault exec shared_services -- aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${DOCKER_ECR}; \
	else \
	  echo "Please set the DOCKER_ECR env var in the .env file to authenticate docker to ECR."; \
	fi
## Note to build for production remove --target flag
BUILD_TARGET=development
version := $(shell cat .ruby-version)
BASE_IMAGE="${DOCKER_ECR}ruby-base:${version}"
build-image: docker-login
	docker build . -t ${DOCKER_ECR}reporting-service:${BUILD_TARGET} \
	--build-arg LOCAL_BUILD=true \
	--target ${BUILD_TARGET} --build-arg BASE_IMAGE=${BASE_IMAGE}

## use this to connect to a running container
connect-image:
	docker container exec -it ${DOCKER_ECR}reporting-service /bin/bash

run-image-bash:
	docker run -it --rm --name reporting-service \
	--entrypoint=/bin/bash \
	--env-file=.env ${DOCKER_ECR}reporting-service:${BUILD_TARGET}


run-image:
	docker run --rm -p ${PORT}:${PORT} --name reporting-service --env-file=.env \
	-v ${PWD}/db:/app/db \
	-v ${PWD}/lib:/app/lib \
	-v ${PWD}/app:/app/app \
	-v ${PWD}/config:/app/config \
	-e REPORTING_DB_HOST=${LOCAL_IP} \
	-v ${PWD}/log:/app/log \
	${DOCKER_ECR}reporting-service:${BUILD_TARGET} \
	"bundle exec unicorn -c config/unicorn.rb -p ${PORT}"
FILE=
run-image-tests:
	docker run -it --rm --env-file=.env  \
	-v ${PWD}/app:/app/app \
	-v ${PWD}/db:/app/db \
	-v ${PWD}/bin:/app/bin \
	-v ${PWD}/lib:/app/lib \
	-v ${PWD}/config:/app/config \
	-v ${PWD}/log:/app/log \
	-v ${PWD}/coverage:/app/coverage \
	-v ${PWD}/spec:/app/spec \
	-v ${PWD}/tmp:/app/tmp \
	-e REPORTING_DB_HOST=${LOCAL_IP} \
	-e REPORTING_DB_PASSWORD='' \
	-e COVERAGE=true \
	-e CI=true \
	-e RAILS_ENV=test \
	--name reporting-service-test \
	${DOCKER_ECR}reporting-service:${BUILD_TARGET} \
	"bundle exec rspec -fd ${FILE}"


