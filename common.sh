#!/bin/bash

# [シェルスクリプトを書くときはset -euしておく - Qiita](https://qiita.com/youcune/items/fcfb4ad3d7c1edf9dc96)
set -eu

readonly input_payroll_csv="input_payroll_csv/payroll_book-*.csv"
readonly output_import_csv_dir="output_import_csv"

mkdir -p ./${output_import_csv_dir}

function encode_payroll() {
  mime_encoding=$(file --mime-encoding $1 | awk '{print $2}')
  if [[ "${mime_encoding}" = 'unknown-8bit' ]]; then
    iconv -f sjis -t utf-8 $1
  elif [[ "${mime_encoding}" = 'utf-8' ]]; then
    cat $1
  else
    echo "no encoding"
    exit 1
  fi
}

PROGNAME=$(basename $0)
VERSION="1.0"
ARG_F=""
ARG_T=""
ARG_D=0

# [awkガナス - 複数ファイルへの出力(リダイレクト機能) | 株式会社創夢 — SOUM/misc](https://www.soum.co.jp/misc/awk/6/)
# [The GNU Awk User's Guide - アクション中の制御文](http://www.kt.rim.or.jp/~kbk/gawk-30/gawk_10.html#SEC107)
function check_yyyymm() {
  gawk -v d=$1 'BEGIN {
    ym = strftime("%Y%m", mktime(substr(d, 1, 4) " " substr(d, 5, 2) " 01 00 00 00"))
    if (ym != d) {
      print "illegal yyyymm : " d > "/dev/stderr"
      exit 1
    }
  }'
}

usage() {
  echo "Usage: $PROGNAME [OPTIONS] FILE"
  echo "  This script is ~."
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "      --version"
  echo "  -f, --from YYYYMM"
  echo "  -t, --to YYYYMM"
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
      echo $VERSION
      exit 1
      ;;
    -f | --from)
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      check_yyyymm $2
      ARG_F=$2
      shift 2
      ;;
    -t | --to)
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      check_yyyymm $2
      ARG_T=$2
      shift 2
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

if [[ -z ${ARG_F} && -n ${ARG_T} ]] || [[ -n ${ARG_F} && -z ${ARG_T} ]] ; then
  echo "illegal option -- set -f and -t together" 
  exit 1
fi

function touch_csv_file() {
  if [[ -n ${ARG_F} && -n ${ARG_T} ]]; then
    csv_file="$1_${ARG_F}-${ARG_T}"
  else
    csv_file="$1_$(date '+%Y%m%d-%H%M%S')"
  fi
}
