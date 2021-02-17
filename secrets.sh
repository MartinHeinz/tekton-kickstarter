populate_secrets () {
  while IFS= read -r LINE; do
    IFS=": " read KEY VALUE <<< "$LINE"
    if [[ $KEY == 'SSH_KEY_PATH' || $KEY == 'SSH_KNOWN_HOST_PATH' ]]; then
      VALUE="$(cat $VALUE | base64 | tr '\n' '\r')"  # Replace newlines with carriage return because `sed` doesn't like newlines
    fi
    sed -i 's#<'"$KEY"'>#'"$VALUE"'#g' ./misc/secrets.yaml
  done < .env
  sed -i 's#\r#\n#g' ./misc/secrets.yaml  # Replace carriage return chars used above
}

populate_secrets