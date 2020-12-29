#!/bin/bash
#
# csvのヘッダー表示が複数ある場合に最初の表示だけする
#

VERSION=1.0

usage() {
  echo "Usage: $PROGNAME [OPTIONS] FILE"
  echo "  csvのヘッダー表示が複数ある場合に最初の表示だけする。"
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "      --version"
  echo "  -d, --debug"
  echo
  exit 1
}

for OPT in "$@"
do
  case $OPT in
    -h | --help)
      usage
      exit 1
      ;;
    --version)
      echo "${VERSION}"
      exit 1
      ;;
    -d | --debug)
      ARG_D=1
      shift 1
      ;;
    -- | -)
      shift 1
      param+=( "$@" )
      break
      ;;
    -*)
      echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      exit 1
      ;;
    *)
      if [[ $# -ge 1 ]] && [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        #param=( ${param[@]} "$1" )
        param+=( "$1" )
        shift 1
      fi
      ;;
  esac
done

awk -v debug="${ARG_D}" '
    !uniq[$0]++
    END {
        if (debug) {
            for (u in uniq) {
                if (uniq[u] > 1) {
                    print "" >"/dev/stderr"
                    print "debug: No uniq list" >"/dev/stderr"
                    print "Count:" uniq[u], u >"/dev/stderr"
                }
            }
        }
    }
'
