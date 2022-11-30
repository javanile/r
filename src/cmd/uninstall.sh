

rsvm_uninstall()
{
  if [ `rsvm_current` = "$1" ]
  then
    echo "rsvm: Cannot uninstall currently-active version, $1"
    return
  fi
  if [ ! -d "$RSVM_DIR/versions/$1" ]
  then
    echo "$1 version is not installed yet..."
    return
  fi
  echo "uninstall $1 ..."

  case $RSVM_OSTYPE in
    Darwin)
      rm -ri "$RSVM_DIR/versions/$1"
      ;;
    *)
      rm -rI "$RSVM_DIR/versions/$1"
      ;;
  esac
}
