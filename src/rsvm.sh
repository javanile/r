
rsvm_check_etag()
{
  # Check which md5sum to use
  if [ -f "$(which md5sum)" ]; then
      MD5=md5sum
  elif [ -f "$(which md5)" ]; then
      MD5=md5
  else
      echo "md5sum not found!"
      exit 1
  fi

  if [ -f $2.etag ]
  then
    curl -s -I -H "If-None-Match:$(cat $2.etag)" $1 | grep 304 | wc -l
  elif [ -f $2 ]
  then
    local ETAG=$($MD5 $2 | awk '{print $1}')
    curl -s -I -H "If-None-Match:\"$ETAG\"" $1 | grep 304 | wc -l
  else
    echo 0
  fi
}

rsvm_file_download()
{
  local OPTS
  # download custom etag
  if [ "$3" = true ]
  then
    curl -I -s $1 | grep ETag | awk '{print $2}' > $2.etag
    OPTS='-#'
  else
    OPTS='-s'
  fi

  #echo $1 $2

  if [ $(rsvm_check_etag $1 $2) = 0 ]
  then
    # not match etag; new download
    curl $OPTS -o $2 $1
  else
    # match etag; resume download
    curl $OPTS -o $2 -C - $1
  fi

}

rsvm_append_path()
{
  local newpath
  if [[ ":$1:" != *":$2:"* ]];
  then
    newpath="${1:+"$1:"}$2"
  else
    newpath="$1"
  fi
  echo $newpath
}

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



rsvm_init_folder_structure()
{
  echo -n "Creating the respective folders for rust $1 ... "

  mkdir -p "$RSVM_DIR/versions/$1/src"
  mkdir -p "$RSVM_DIR/versions/$1/dist"

  echo "done"
}

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
