
rsvm_current()
{
  if [ ! -e "$RSVM_DIR/current" ]
  then
    echo "N/A"
    return
  fi
  target=`echo $(readlink "$RSVM_DIR/current"|tr "/" "\n")`
  echo ${target[@]} | awk '{print$NF}'
}
