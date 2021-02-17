secrets:
	@bash secrets.sh

configure: secrets
	@kubectl apply -f config/ -n tekton-pipelines

cluster:
	@if [ $$(kind get clusters | grep tekton | wc -l) = 0 ]; then \
		kind create cluster --config ./kind/kind.yaml --name tekton --image=kindest/node:v1.20.2; \
		@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml; \
	fi
	@kubectl cluster-info --context kind-tekton
	@kubectl config set-context kind-tekton

operator:
	@curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.17.0/install.sh | bash -s v0.17.0
	@kubectl create -f https://operatorhub.io/install/tektoncd-operator.yaml
	# TODO wait for resouces to be created and call `configure` target

deploy-triggers:
	@kubectl apply -f triggers/

deploy-tasks:
	@kubectl apply -f tasks/

deploy-pipelines:
	@kubectl apply -f pipelines/

deploy:
	@kubectl apply -f misc/
	deploy-triggers
	deploy-tasks
	deploy-pipelines

debug:
	# TODO target to rsh into pod of crashed TaskRun