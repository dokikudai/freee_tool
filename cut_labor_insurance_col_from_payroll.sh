#!/bin/bash
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
        -f cut_labor_insurance_col_from_payroll.awk \
        <(encode_payroll ${csv_list})
  done
