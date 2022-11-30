
rsvm_ls_remote()
{
  local VERSIONS
  local STABLE_VERSION

  if [ -z $RSVM_PLATFORM ]
  then
    echo "rsvm: Not support this platform, $RSVM_OSTYPE"
    return
  fi

  STABLE_VERSION=$(rsvm_ls_channel stable)
  rsvm_file_download https://static.rust-lang.org/dist/index.txt "$RSVM_DIR/cache/index.txt"
  VERSIONS=$(cat "$RSVM_DIR/cache/index.txt" \
    | command egrep -o "^/dist/rust-$RSVM_NORMAL_PATTERN-$RSVM_PLATFORM.tar.gz" \
    | command egrep -o "$RSVM_VERSION_PATTERN" \
    | command sort \
    | command uniq)
  for VERSION in $VERSIONS;
  do
    if [ "$STABLE_VERSION" = "$VERSION" ]
    then
      continue
    fi
    echo $VERSION
  done
  echo $STABLE_VERSION
  rsvm_ls_channel staging
  rsvm_ls_channel beta
  rsvm_ls_channel nightly
}
