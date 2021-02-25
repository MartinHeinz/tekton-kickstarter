install_catalog_tasks() {
  while IFS= read -r LINE; do
    IFS=": " read KEY VALUE <<< "$LINE"
    kubectl apply -f $VALUE
  done < ./tasks/catalog.yaml
}

install_custom_tasks() {
  for FILENAME in tasks/*; do
    if [ -d "$FILENAME" ]; then
        kubectl apply -f ${FILENAME}/*.yaml
    fi
  done
}

install_catalog_tasks
install_custom_tasks
kubectl get tasks,clustertasks