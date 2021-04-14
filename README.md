# Tekton CI/CD Kickstarter

<p align="center">
<img src="cover.png" alt="Cover Image"></img>
</p>

Scripts, configs and resources for quick and easy setup of Tekton Pipelines.

## Blog Posts - More Information About This Repo

You can find more information about this project/repository and how to use it in following blog post:

- [Cloud Native CI/CD with Tekton  -  Laying The Foundation](https://martinheinz.dev/blog/45)
- [Cloud Native CI/CD with Tekton - Building Custom Tasks](https://martinheinz.dev/blog/47)

## Prerequisites

- `jq`
- `kubectl`
- `kind`

Also recommended:

- `tkn`
- `yamllint`

## Setting Up

- Populate variables in `.env`
- Run `make secrets` and verify generated secret values in `./misc/secrets.yaml`
- Run `make` to deploy core components (KinD cluster, Pipelines, Tasks, Triggers, Event listener Ingress)
    - Event listener Ingress is available at `localhost/`. You can test sample pipeline with:
    
```shell
~ $ curl -H 'X-GitHub-Event: push' \
    -H 'Content-Type: application/json' \
    -d '{
      "repository": {"ssh_url": "git@github.com:kelseyhightower/nocode.git"},
      "head_commit": {"id": "6c073b08f7987018cbb2cb9a5747c84913b3608e", "message": "add style guide"},
      "ref": "refs/heads/master"
    }' \
    localhost

~ $ kubectl get pr
NAME           SUCCEEDED   REASON    STARTTIME   COMPLETIONTIME
deploy-nd8r5   Unknown     Running   10s        

~ $ kubectl get tr
NAME                                      SUCCEEDED   REASON      STARTTIME   COMPLETIONTIME
deploy-nd8r5-build-sngns                  True        Succeeded   2m5s        113s
deploy-nd8r5-clean-z7hww                  True        Succeeded   112s        104s
deploy-nd8r5-deploy-bnq65                 True        Succeeded   113s        106s
deploy-nd8r5-dive-nt9fd                   True        Succeeded   113s        103s
deploy-nd8r5-fetch-repository-9s8q8       True        Succeeded   2m14s       2m5s
deploy-nd8r5-generate-build-id-9lfcq      True        Succeeded   2m22s       2m16s
deploy-nd8r5-get-application-name-jfn57   True        Succeeded   2m22s       2m15s
deploy-nd8r5-healthcheck-68thd            True        Succeeded   105s        2m15s
deploy-nd8r5-notify-f8gha                 True        Succeeded   2m15s       2m20s
```

- Optionally deploy dashboard with `make dashboard`
    - This also creates Ingress - dashboard is available at `localhost/dashboard/` (URL must include trailing `/`)

## Layout

Layout of files in the project:
```
tekton-kickstarter
├── config                     - Tekton Pipelines configurations - Defaults for Tasks and Pipelines + Feature flags
├── dashboard                  - Resources for Tekton Dashboard - Ingress
├── kind                       - Custom configuration for KinD cluster for local development
├── Makefile                   - Make targets for simple provisioning and setup
├── misc                       - Miscellaneous configuration files, such as ServiceAccounts, RBAC, Secrets (SSH keys, Docker) or Quotas
|
├── pipelines                  - Actuals pipelines, one pipeline per file + test for each
│   └── pipeline-name          - Directory containing pipeline
│       ├── pipeline-name.yaml - File containing Pipeline
│       └── tests              - Directory with files for testing
│           ├── resources.yaml - Resources required for testing, e.g. PVC, Deployment
│           └── run.yaml       - PipelineRun(s) that performs the test
|
├── tasks                      - Custom or remotely retrieved Tasks and ClusterTasks
│   ├── catalog.yaml           - List of Tasks retrieved from remote registries (e.g. Tekton catalog)
│   └── task-name              - Other custom Task
|     ├── task-name.yaml       - File containing Task or ClusterTask
|     └── tests                - Directory with files for testing
|         ├── resources.yaml   - Resources required for testing, e.g. PVC, Deployment
|         └── run.yaml         - TaskRun(s) that performs the test
|
└── triggers  - Tekton Triggers files
    ├── cron  - Cron-based pipeline triggers and CronJobs to generate events
    └── http  - HTTP-based pipeline triggers and Ingress/Route to make it reachable
```
