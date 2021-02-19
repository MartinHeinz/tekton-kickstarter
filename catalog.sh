install_catalog_tasks () {
  while IFS= read -r LINE; do
    IFS=": " read KEY VALUE <<< "$LINE"
    kubectl apply -f $VALUE
  done < ./tasks/catalog.yaml
  kubectl get tasks,clustertasks
}

install_catalog_tasks