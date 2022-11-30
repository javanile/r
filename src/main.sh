
# Rust Version Manager
# ====================
#
# To use the rsvm command source this file from your bash profile.

module env
module init

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
