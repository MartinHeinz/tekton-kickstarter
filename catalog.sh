install_catalog_tasks () {
  while IFS= read -r LINE; do
    IFS=": " read KEY VALUE <<< "$LINE"
    kubectl apply -f $VALUE
  done < ./tasks/catalog.yaml
}

install_custom_tasks () {
  for FILENAME in ./tasks/*.yaml; do
    if [ $FILENAME != "./tasks/catalog.yaml" ]; then
      kubectl apply -f $FILENAME -l type=core
    fi
done
}

install_catalog_tasks
install_custom_tasks
kubectl get tasks,clustertasks