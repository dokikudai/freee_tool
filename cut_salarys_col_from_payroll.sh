#!/bin/bash
#
# freeeの賃金台帳（payroll）から必要項目だけ切り出す
# bug: from, to オプションは賞与に対応していないので後日修正
#
source ./common.sh

ls -1 ./${input_payroll_csv} \
| while read -r csv_list
  do
    awk -v v_debug_lfg=${ARG_D} \
        -v v_from=${ARG_F} \
        -v v_to=${ARG_T} \
        -F ',' \
        -f cmn.awk \
        -f property.awk \
        -f payroll_use_idx_salarys.awk \
        -f cmn_cut_col_from_payroll.awk \
        <(encode_payroll ${csv_list})
  done
