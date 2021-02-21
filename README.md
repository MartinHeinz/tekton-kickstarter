# Tekton CI/CD Kickstarter

Scripts, configs and resources for quick and easy setup of Tekton Pipelines.

## Prerequisites

- `jq`
- `kubectl`
- `kind`

Also recommended:

- `tkn`

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
