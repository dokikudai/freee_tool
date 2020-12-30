#!/bin/bash
source ./common.sh

awk -v v_debug_lfg=${ARG_D} \
    -v v_from=${ARG_F} \
    -v v_to=${ARG_T} \
    -F ',' \
    -f cmn.awk \
    -f property.awk \
    -f make_csv_labor_insurance.awk
