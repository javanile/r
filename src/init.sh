



rsvm_initialize()
{
  if [ ! -d "$RSVM_DIR/versions" ]
  then
    mkdir -p "$RSVM_DIR/versions"
  fi
  if [ ! -f "$RSVM_DIR/.rsvm_version" ]
  then
    touch "$RSVM_DIR/.rsvm_version"
  fi
  local rsvm_version=$(cat "$RSVM_DIR/.rsvm_version")
  if [ -z "$rsvm_version" ]
  then
    local DIRECTORIES=$(find "$RSVM_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename '{}' \; \
      | sort \
      | egrep "^$RSVM_VERSION_PATTERN")

    mkdir -p "$RSVM_DIR/versions"
    for line in $(echo $DIRECTORIES | tr " " "\n")
    do
      mv "$RSVM_DIR/$line" "$RSVM_DIR/versions"
    done
  fi
  echo "1" > "$RSVM_DIR/.rsvm_version"
}

