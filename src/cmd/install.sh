
rsvm_install()
{
  local CURRENT_DIR=`pwd`
  local target=$1
  local with_rustc_source=$2
  local dirname
  local url_prefix
  local LAST_VERSION
  local RUSTUP_CHANNEL

  if [ ${1: -3} = '-rc' ]
  then
    url_prefix='/staging/dist'
    target=${1%%-rc}
  fi

  if [[ $1 = "nightly" ]] || [[ $1 = "beta" ]] || [ ${1: -3} = '-rc' ]
  then
    # if same version reuse directory
    LAST_VERSION=$(rsvm_ls|grep $1|tail -n 1|awk '{print $2}')
    if [ $(rsvm_check_etag \
             "https://static.rust-lang.org/dist$url_prfix/rust-$target-$RSVM_PLATFORM.tar.gz" \
             "$RSVM_DIR/versions/$LAST_VERSION/src/rust-$target-$RSVM_PLATFORM.tar.gz") = 1 ]
    then
      dirname=$LAST_VERSION
    else
      dirname=$1.`date "+%Y%m%d%H%M%S"`
    fi
    if [[ $1 = "nightly" ]]
    then
      RUSTUP_CHANNEL=$1
    else
      RUSTUP_CHANNEL="beta"
    fi
  else
    dirname=$1
    RUSTUP_CHANNEL=$1
  fi

  rsvm_init_folder_structure $dirname
  local SRC="$RSVM_DIR/versions/$dirname/src"
  local DIST="$RSVM_DIR/versions/$dirname/dist"
  local CARGO="$RSVM_DIR/versions/$dirname/cargo"
  local RUSTUP="$RSVM_DIR/versions/$dirname/rustup"

  cd $SRC

  if [ -z $RSVM_PLATFORM ]
  then
    echo "rsvm: Not support this platform, $RSVM_OSTYPE"
    return
  fi

  echo "Downloading sources for rust $dirname ... "
  rsvm_file_download \
    "https://static.rust-lang.org/dist$url_prfix/rust-$target-$RSVM_PLATFORM.tar.gz" \
    "rust-$target-$RSVM_PLATFORM.tar.gz" \
    true

  if [ -e "rust-$target" ]
  then
    echo "Sources for rust $dirname already extracted ..."
  else
    echo -n "Extracting source ... "
    tar -xzf "rust-$target-$RSVM_PLATFORM.tar.gz"
    mv "rust-$target-$RSVM_PLATFORM" "rust-$target"
    echo "done"
  fi

  if [ "$with_rustc_source" = true ]
  then
    echo "Downloading sources for rustc sourcecode $dirname ... "
    rsvm_file_download \
      "https://static.rust-lang.org/dist$url_prfix/rustc-$target-src.tar.gz" \
      "rustc-$target-src.tar.gz" \
      true
    if [ -e "rustc-source" ]
    then
      echo "Sources for rustc $dirname already extracted ..."
    else
      echo -n "Extracting source ... "
      tar -xzf "rustc-$target-src.tar.gz"
      mv "rustc-$target" "rustc-source"
    fi
  fi

  if [ ! -f $SRC/rust-$target/bin/cargo ] && [ ! -f $SRC/rust-$target/cargo/bin/cargo ]
  then
    echo "Downloading sources for cargo nightly ... "
    rsvm_file_download \
      "https://static.rust-lang.org/cargo-dist/cargo-nightly-$RSVM_PLATFORM.tar.gz" \
      "cargo-nightly-$RSVM_PLATFORM.tar.gz" \
      true

    echo -n "Extracting source ... "
    tar -xzf "cargo-nightly-$RSVM_PLATFORM.tar.gz"
    mv "cargo-nightly-$RSVM_PLATFORM" "cargo-nightly"
    echo "done"

    cd "$SRC/cargo-nightly"
    sh install.sh --prefix=$DIST
  fi

  cd "$SRC/rust-$target"
  sh install.sh --prefix=$DIST

  if [ ! -f $DIST/lib/rustlib/multirust-channel-manifest.toml ]
  then
    echo "Downloading channel manifest ... "
    rsvm_file_download \
      "https://static.rust-lang.org/dist/channel-rust-${RUSTUP_CHANNEL}.toml" \
      "multirust-channel-manifest.toml"
    echo "done"

    cp multirust-channel-manifest.toml $DIST/lib/rustlib/multirust-channel-manifest.toml
  fi

  if [ ! -f $DIST/lib/rustlib/multirust-config.toml ]
  then
    cat << EOF > $DIST/lib/rustlib/multirust-config.toml
config_version = "1"

[[components]]
pkg = "rustc"
target = "$RSVM_PLATFORM"

[[components]]
pkg = "rust-std"
target = "$RSVM_PLATFORM"

[[components]]
pkg = "cargo"
target = "$RSVM_PLATFORM"

[[components]]
pkg = "rust-docs"
target = "$RSVM_PLATFORM"
EOF
  fi

  if [ ! -f $DIST/bin/rustup ]
  then
    echo "Downloading rustup ... "
    rsvm_file_download \
      "https://static.rust-lang.org/rustup/dist/$RSVM_PLATFORM/rustup-init" \
      "rustup"
    echo "done"

    cp rustup $DIST/bin/rustup
    chmod +x $DIST/bin/rustup
  fi

  mkdir -p $RUSTUP/toolchains
  ln -s $DIST $RUSTUP/toolchains/${RUSTUP_CHANNEL}-${RSVM_PLATFORM}
  cat << EOF > $RUSTUP/settings.toml
default_host_triple = "x86_64-unknown-linux-gnu"
default_toolchain = "nightly-x86_64-unknown-linux-gnu"
telemetry = false
version = "12"

[overrides]
EOF

  echo ""
  echo "And we are done. Have fun using rust $dirname."

  cd $CURRENT_DIR
  RSVM_LAST_INSTALLED_VERSION=$dirname
}
