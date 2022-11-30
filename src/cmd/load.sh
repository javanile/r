
rsvm_install()
{
  export LD_LIBRARY_PATH=$(rsvm_append_path $LD_LIBRARY_PATH "$RSVM_DIR/current/dist/lib")
  export DYLD_LIBRARY_PATH=$(rsvm_append_path $DYLD_LIBRARY_PATH "$RSVM_DIR/current/dist/lib")
  export MANPATH=$(rsvm_append_path $MANPATH "$RSVM_DIR/current/dist/share/man")
  export RSVM_SRC_PATH="$RSVM_DIR/current/src/rustc-source/src"
  if [ -e "$RSVM_SRC_PATH" ]
  then
    export RUST_SRC_PATH="$RSVM_SRC_PATH"
  else
    unset RUST_SRC_PATH
  fi
  export CARGO_HOME="$RSVM_DIR/current/cargo"
  export RUSTUP_HOME="$RSVM_DIR/current/rustup"

  export PATH=$(rsvm_append_path $PATH "$RSVM_DIR/current/dist/bin")
  export PATH=$(rsvm_append_path $PATH "$CARGO_HOME/bin")
}