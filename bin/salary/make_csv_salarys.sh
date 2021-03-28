#!/bin/bash
#
# freeeの賃金台帳.csv（payroll.csv）からfreee労働保険料仕訳を作成する
#
source ./bin/common.sh

awk -v v_debug_lfg=${ARG_D} \
    -v v_from=${ARG_F} \
    -v v_to=${ARG_T} \
    -F ',' \
    -f ./bin/cmn.awk \
    -f ./bin/property.awk \
    -f ./bin/salary/make_csv_salarys.awk \
    -f ./bin/cmn_make_csv.awk
