
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
