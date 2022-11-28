
rsvm_use()
{
  if [ -e "$RSVM_DIR/versions/$1" ]
  then
    echo -n "Activating rust $1 ... "

    rm -rf "$RSVM_DIR/current"
    ln -s "$RSVM_DIR/versions/$1" "$RSVM_DIR/current"
    source $RSVM_SCRIPT

    echo "done"
  else
    echo "The specified version $1 of rust is not installed..."
    echo "You might want to install it with the following command:"
    echo ""
    echo "rsvm install $1"
  fi
}
