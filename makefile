IMAGE_REG ?= ghcr.io
IMAGE_REPO ?= benc-uk/postman-prometheus
IMAGE_TAG ?= latest

# Used when running locally
COLLECTION_FILE ?= ./samples/my-blog.json

# Used when deploying to Kubernetes
DEPLOY_NAMESPACE ?= default
DEPLOY_SUFFIX ?= blog
DEPLOY_ITERATIONS ?= 2
DEPLOY_INTERVAL ?= 30
DEPLOY_COLLECTION_URL ?= https://raw.githubusercontent.com/benc-uk/postman-prometheus/main/samples/my-blog.json
DEPLOY_BAIL ?= false
DEPLOY_IMAGE := $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: help lint lint-fix image push run deploy undeploy .EXPORT_ALL_VARIABLES
.DEFAULT_GOAL := help

help:  ## This help message 😁
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: node_modules  ## Lint & format, will not fix but sets exit code on error 🔎
	npm run lint

lint-fix: node_modules  ## Lint & format, will try to fix errors and modify code 📜
	npm run lint-fix

image:  ## Build container image from Dockerfile 🔨
	docker build . --file ./Dockerfile \
	--tag $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

push:  ## Push container image to registry 📤
	docker push $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

run: node_modules .EXPORT_ALL_VARIABLES  ## Run locally using Node.js 🏃‍
	npm start

deploy: .EXPORT_ALL_VARIABLES  ## Deploy to Kubernetes 🚀
	 cat deploy/deployment.yaml | envsubst | kubectl apply -f -

undeploy: .EXPORT_ALL_VARIABLES  ## Remove from Kubernetes 💀
	 cat deploy/deployment.yaml | envsubst | kubectl delete -f - || true

node_modules: package.json
	npm install --silent
	touch -m node_modules

package.json: 
	@echo "package.json was modified"
