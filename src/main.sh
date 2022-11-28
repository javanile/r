
# Rust Version Manager
# ====================
#
# To use the rsvm command source this file from your bash profile.

RSVM_VERSION="0.5.1"
RSVM_NIGHTLY_PATTERN="nightly(\.[0-9]+)?"
RSVM_BETA_PATTERN="beta(\.[0-9]+)?"
RSVM_NORMAL_PATTERN="[0-9]+\.[0-9]+(\.[0-9]+)?(-(alpha|beta)(\.[0-9]*)?)?"
RSVM_RC_PATTERN="$RSVM_NORMAL_PATTERN-rc(\.[0-9]+)?"
RSVM_VERSION_PATTERN="($RSVM_NIGHTLY_PATTERN|$RSVM_NORMAL_PATTERN|$RSVM_RC_PATTERN|$RSVM_BETA_PATTERN)"
RSVM_LAST_INSTALLED_VERSION=

if [ -n "$ZSH_VERSION" ]
then
  RSVM_SCRIPT=${(%):-%N}
  RSVM_SCRIPT="$(cd -P "$(dirname "$RSVM_SCRIPT")" && pwd)/$(basename "$RSVM_SCRIPT")"
else
  RSVM_SCRIPT=${BASH_SOURCE[0]}
fi

RSVM_ARCH=`uname -m`
RSVM_OSTYPE=`uname -s`
case $RSVM_OSTYPE in
  Linux)
    RSVM_PLATFORM=$RSVM_ARCH-unknown-linux-gnu
    ;;
  Darwin)
    RSVM_PLATFORM=$RSVM_ARCH-apple-darwin
    ;;
  *)
    ;;
esac

# Auto detect the RSVM_DIR
if [ ! -d "$RSVM_DIR" ]
then
  export RSVM_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}) && pwd)
fi

# shellcheck disable=SC2120
main() {
  rsvm_initialize

  case $1 in
    ""|help|--help|-h)
      echo ''
      echo 'Rust Version Manager'
      echo '===================='
      echo ''
      echo 'Usage:'
      echo ''
      echo '  rsvm help | --help | -h       Show this message.'
      echo '  rsvm install <version>        Download and install a <version>.'
      echo '                                <version> could be for example "0.12.0".'
      echo '  rsvm uninstall <version>      Uninstall a <version>.'
      echo '  rsvm use <version>            Activate <version> for now and the future.'
      echo '  rsvm ls | list                List all installed versions of rust.'
      echo '  rsvm ls-remote                List remote versions available for install.'
      echo '  rsvm ls-channel               Print a channel version available for install.'
      echo ''
      echo "Current version: $RSVM_VERSION"
      ;;
    --version|-v)
      echo "v$RSVM_VERSION"
      ;;
    install)
      if [ -z "$2" ]
      then
        # whoops. no version found!
        echo "Please define a version of rust!"
        echo ""
        echo "Example:"
        echo "  rsvm install 0.12.0"
      elif ([[ "$2" =~ ^$RSVM_VERSION_PATTERN$ ]])
      then
        local version=$2
        local with_rustc_source=true
        for i in ${@:3:${#@}}
        do
          case $i in
            --dry)
              echo "Would install rust $version"
              RSVM_LAST_INSTALLED_VERSION=$version
              rsvm_use $RSVM_LAST_INSTALLED_VERSION
              exit
              ;;
            --without-rustc-source)
              with_rustc_source=false
              ;;
            *)
              ;;
          esac
        done
        rsvm_install "$version" "$with_rustc_source"
        rsvm_use $RSVM_LAST_INSTALLED_VERSION
      else
        # the version was defined in a the wrong format.
        echo "You defined a version of rust in a wrong format!"
        echo "Please use either <major>.<minor> or <major>.<minor>.<patch>."
        echo ""
        echo "Example:"
        echo "  rsvm install 0.12.0"
      fi
      ;;
    ls|list)
      rsvm_ls
      ;;
    ls-remote)
      rsvm_ls_remote
      ;;
    ls-channel)
      if [ -z "$2" ]
      then
        # whoops. no channel found!
        echo "Please define a channel of rust!"
        echo ""
        echo "Example:"
        echo "  rsvm ls-channel stable"
      else
        rsvm_ls_channel $2
      fi
      ;;
    use)
      if [ -z "$2" ]
      then
        # whoops. no version found!
        echo "Please define a version of rust!"
        echo ""
        echo "Example:"
        echo "  rsvm use 0.12.0"
      elif ([[ "$2" =~ ^$RSVM_VERSION_PATTERN$ ]])
      then
        rsvm_use "$2"
      else
        # the version was defined in a the wrong format.
        echo "You defined a version of rust in a wrong format!"
        echo "Please use either <major>.<minor> or <major>.<minor>.<patch>."
        echo ""
        echo "Example:"
        echo "  rsvm use 0.12.0"
      fi
      ;;
    uninstall)
      if [ -z "$2" ]
      then
        # whoops. no version found!
        echo "Please define a version of rust!"
        echo ""
        echo "Example:"
        echo "  rsvm use 0.12.0"
      elif ([[ "$2" =~ ^$RSVM_VERSION_PATTERN$ ]])
      then
        rsvm_uninstall "$2"
      else
        # the version was defined in a the wrong format.
        echo "You defined a version of rust in a wrong format!"
        echo "Please use either <major>.<minor> or <major>.<minor>.<patch>."
        echo ""
        echo "Example:"
        echo "  rsvm uninstall 0.12.0"
      fi
      ;;
    *)
      rsvm
  esac

  echo ''
}
