all: cluster operator deploy
	cluster
	operator
	deploy

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

operator:
	@echo "\nDeploying Operator\n"
	@curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.17.0/install.sh | bash -s v0.17.0
	@kubectl create -f https://operatorhub.io/install/tektoncd-operator.yaml
	while : ; do \
	  kubectl get namespace tekton-pipelines && break; \
	  sleep 5; \
	done; \
	while : ; do \
	  kubectl get cm config-defaults -n tekton-pipelines && break; \
	  sleep 5; \
	done

deploy: deploy-config deploy-triggers deploy-tasks deploy-pipelines
	@echo "\nDeploying configs and pipelines\n"
	deploy-config
	@kubectl apply -f misc/
	deploy-triggers
	deploy-tasks
	deploy-pipelines

deploy-config:
	@kubectl apply -f config/ -n tekton-pipelines
	@kubectl apply -f misc/

deploy-triggers:
	@kubectl apply -R -f triggers/

deploy-tasks:
	@bash catalog.sh

deploy-pipelines:
	@kubectl apply -f pipelines/

secrets:
	@bash secrets.sh

debug:
	# TODO target to rsh into pod of crashed TaskRun