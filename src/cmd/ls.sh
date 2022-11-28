
rsvm_ls()
{
  DIRECTORIES=$(find "$RSVM_DIR/versions" -maxdepth 1 -mindepth 1 -type d -exec basename '{}' \; \
    | sort \
    | egrep "^$RSVM_VERSION_PATTERN")

  echo "Installed versions:"
  echo ""

  if [ $(egrep -o "^$RSVM_VERSION_PATTERN" <<< "$DIRECTORIES" | wc -l) = 0 ]
  then
    echo '  -  None';
  else
    for line in $(echo $DIRECTORIES | tr " " "\n")
    do
      if [ `rsvm_current` = "$line" ]
      then
        echo "  =>  $line"
      else
        echo "  -   $line"
      fi
    done
  fi
}

