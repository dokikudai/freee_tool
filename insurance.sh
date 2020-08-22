#!/bin/bash
source ./common.sh

touch_csv_file "insurance"

i=1

ls -1 ./${input_payroll_csv} \
| while read -r csv_list
  do
    awk -v v_debug_lfg=${ARG_D} \
        -v v_from=${ARG_F} \
        -v v_to=${ARG_T} \
        -v v_csv_list=${csv_list} \
        -F ',' \
        -f cmn.awk \
        -f cmn_insra.awk \
        -f insurance.awk \
        social_insurances/*.tmp \
        <(encode_payroll ${csv_list}) \
        > ./${output_import_csv_dir}/${csv_file}_${i}.csv

    i=$((++i))
  done
