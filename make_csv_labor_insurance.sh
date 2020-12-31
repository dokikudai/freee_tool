#!/bin/bash
#
# freeeの賃金台帳.csv（payroll.csv）からfreee労働保険料仕訳を作成する
#
source ./common.sh

awk -v v_debug_lfg=${ARG_D} \
    -v v_from=${ARG_F} \
    -v v_to=${ARG_T} \
    -F ',' \
    -f cmn.awk \
    -f property.awk \
    -f make_csv_labor_insurance.awk
