install_pipelines() {
  for FILE in pipelines/*; do
      if [ -d "$FILE" ]; then
          kubectl apply -f ${FILE}/*.yaml
      fi
  done
}

install_pipelines
