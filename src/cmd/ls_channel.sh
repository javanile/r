
rsvm_ls_channel()
{
  local VERSIONS
  local POSTFIX

  if [ -z $RSVM_PLATFORM ]
  then
    echo "rsvm: Not support this platform, $RSVM_OSTYPE"
    return
  fi

  case $1 in
    staging|rc)
      POSTFIX='-rc'
      rsvm_file_download https://static.rust-lang.org/dist/staging/dist/channel-rust-stable "$RSVM_DIR/cache/channel-rust-staging"
      VERSIONS=$(cat "$RSVM_DIR/cache/channel-rust-staging" \
        | command egrep -o "rust-$RSVM_VERSION_PATTERN-$RSVM_PLATFORM.tar.gz" \
        | command egrep -o "$RSVM_VERSION_PATTERN" \
        | command sort \
        | command uniq)
      ;;
    stable|beta|nightly)
      rsvm_file_download https://static.rust-lang.org/dist/channel-rust-$1 "$RSVM_DIR/cache/channel-rust-$1"
      VERSIONS=$(cat "$RSVM_DIR/cache/channel-rust-$1" \
        | command egrep -o "rust-$RSVM_VERSION_PATTERN-$RSVM_PLATFORM.tar.gz" \
        | command egrep -o "$RSVM_VERSION_PATTERN" \
        | command sort \
        | command uniq)
      ;;
    *)
      echo "rsvm: Not support this channel, $1"
      return
      ;;
  esac

  for VERSION in $VERSIONS;
  do
    echo $VERSION$POSTFIX
  done
}
