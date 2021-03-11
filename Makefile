BLUE=\033[0;34m
NC=\033[0m  # No Color

all: cluster tekton deploy

cluster:
	@if [ $$(kind get clusters | grep tekton | wc -l) = 0 ]; then \
		kind create cluster --config ./kind/kind.yaml --name tekton --image=kindest/node:v1.20.2; \
	fi
	@kubectl cluster-info --context kind-tekton
	@kubectl config set-context kind-tekton
	@echo "\n${BLUE}Deploying Ingress...${NC}\n"
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	@echo "\n${BLUE}Waiting for resources to be created (100s)${NC}\n"
	@sleep 10
	@kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

tekton:
	@echo "\n${BLUE}Deploying Tekton Pipelines...${NC}\n"
	@kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	@while : ; do \
	  kubectl get namespace tekton-pipelines && break; \
	  sleep 5; \
	done;
	@while : ; do \
	  kubectl get cm config-defaults -n tekton-pipelines && break; \
	  sleep 5; \
	done
	@kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
	@while : ; do \
	  kubectl get crd eventlisteners.triggers.tekton.dev -n tekton-pipelines && break; \
	  sleep 5; \
	done
	@while : ; do \
	  kubectl get deployment.apps/tekton-pipelines-webhook -n tekton-pipelines && break; \
	  sleep 5; \
	done
	@echo "\n${BLUE}Wating for resources to be ready...${NC}\n"
	@kubectl wait --for=condition=available --timeout=90s deployment.apps/tekton-pipelines-webhook -n tekton-pipelines

deploy: deploy-config deploy-triggers deploy-tasks deploy-pipelines

deploy-config:
	@echo "\n${BLUE}Applying custom config...${NC}\n"
	@kubectl apply -f config/ -n tekton-pipelines
	@kubectl apply -f misc/

deploy-triggers:
	@echo "\n${BLUE}Deploying Tekton Triggers...${NC}\n"
	@kubectl apply -R -f triggers/

deploy-tasks:
	@echo "\n${BLUE}Deploying task catalog...${NC}\n"
	@bash scripts/catalog.sh

deploy-pipelines:
	@echo "\n${BLUE}Deploying pipelines...${NC}\n"
	@bash scripts/pipelines.sh

secrets:
	@echo "\n${BLUE}Generating secrets...${NC}\n"
	@bash secrets.sh

dashboard:
	@echo "\n${BLUE}Deploying Tekton Dashboard${NC}\n"
	@kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
	@kubectl apply -f dashboard/

debug:
	# TODO target to rsh into pod of crashed TaskRun

.PHONY: dashboard