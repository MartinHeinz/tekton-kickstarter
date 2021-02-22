all: cluster tekton deploy

cluster:
	@if [ $$(kind get clusters | grep tekton | wc -l) = 0 ]; then \
		kind create cluster --config ./kind/kind.yaml --name tekton --image=kindest/node:v1.20.2; \
	fi
	@kubectl cluster-info --context kind-tekton
	@kubectl config set-context kind-tekton
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	@echo "\nWaiting for resources to be created (100s)\n"
	@sleep 10
	@kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

tekton:
	@echo "\nDeploying Tekton\n"
	@kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	while : ; do \
	  kubectl get namespace tekton-pipelines && break; \
	  sleep 5; \
	done; \
	while : ; do \
	  kubectl get cm config-defaults -n tekton-pipelines && break; \
	  sleep 5; \
	done
	@kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
	while : ; do \
	  kubectl get crd eventlisteners.triggers.tekton.dev -n tekton-pipelines && break; \
	  sleep 5; \
	done
	while : ; do \
	  kubectl get deployment.apps/tekton-pipelines-webhook -n tekton-pipelines && break; \
	  sleep 5; \
	done
	kubectl wait --for=condition=available --timeout=90s deployment.apps/tekton-pipelines-webhook -n tekton-pipelines

deploy: deploy-config deploy-triggers deploy-tasks deploy-pipelines

deploy-config:
	@kubectl apply -f config/ -n tekton-pipelines
	@kubectl apply -f misc/

deploy-triggers:
	@kubectl apply -R -f triggers/

deploy-tasks:
	@bash catalog.sh

deploy-pipelines:
	@kubectl apply -f pipelines/ -l type=core

secrets:
	@bash secrets.sh

dashboard:
	@kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
	@kubectl apply -f dashboard/

debug:
	# TODO target to rsh into pod of crashed TaskRun

.PHONY: dashboard