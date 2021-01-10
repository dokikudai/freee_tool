#!/bin/bash
#
# 標準出力をファイル化する
# freee 取引のインポート専用スクリプトのため微妙な気がしている
#
source ./common.sh

output_path=
save_file_name="labor_insurance"

awk -F',' \
-v save_file_name="${save_file_name}" \
-v output_path="${output_import_csv_dir}" \
'
    {
        to_data[++i]=$0
    }
    NR == 2 {
        _start_yymm = to_yyyymm($3)
    }
    $3 {
        _end_yymm = to_yyyymm($3)
    }

    END {
        save_file="./" output_path "/" save_file_name "_" _start_yymm "_" _end_yymm ".csv"
        printf "" >save_file
        PROCINFO["sorted_in"]="@ind_num_asc"
        for (data in to_data) {
            print to_data[data] >>save_file
        }
    }

    function to_yyyymm(date, yyyymmdd) {
        split(date,yyyymmdd,"/")
        return sprintf(yyyymmdd[1] yyyymmdd[2])
    }
'
