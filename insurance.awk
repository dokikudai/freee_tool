BEGIN {
  cmn_debug_log("BEGIN")
  PROCINFO["sorted_in"]="@ind_str_asc"
  HEALTH_INSURANCE_ALL_lt40  = "健康保険料全額（39歳以下）"
  HEALTH_INSURANCE_HALF_lt40 = "健康保険料折半（39歳以下）"
  HEALTH_INSURANCE_ALL_ge40  = "健康保険料全額（40歳以上）"
  HEALTH_INSURANCE_HALF_ge40 = "健康保険料折半（40歳以上）"
  WELFARE_PENSION_ALL        = "厚生年金保険料全額"
  WELFARE_PENSION_HALF       = "厚生年金保険料折半"
  CHILD_CARE_PERCENTAGE      = "子ども・子育て拠出金率"
}

FILENAME ~ /.*.tmp/ {
  if ($1 == "") {
    $1=0
  }
  if ($2 == "") {
    $2 = 999999999999
  }
}
FILENAME == "social_insurances/h30ippan4.csv.tmp" {
  set_lib_si(mktime("2018 04 01 00 00 00"), mktime("2019 03 01 00 00 00"))
}
FILENAME == "social_insurances/h31ippan3.csv.tmp" {
  set_lib_si(mktime("2019 03 01 00 00 00"), mktime("2019 04 01 00 00 00"))
}
FILENAME == "social_insurances/h310402.csv.tmp" {
  set_lib_si(mktime("2019 04 01 00 00 00"), mktime("2020 03 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan3.csv.tmp" {
  set_lib_si(mktime("2020 03 01 00 00 00"), mktime("2020 04 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan4.csv.tmp" {
  set_lib_si(mktime("2020 04 01 00 00 00"), mktime("2020 09 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan9.csv.tmp" {
  set_lib_si(mktime("2020 09 01 00 00 00"), mktime("2021 03 01 00 00 00"))
}
FILENAME == "social_insurances/r3ippan3.csv.tmp" {
  set_lib_si(mktime("2021 03 01 00 00 00"), mktime("2022 03 01 00 00 00"))
}
FILENAME == "social_insurances/r4ippan3.csv.tmp" {
  set_lib_si(mktime("2022 03 01 00 00 00"), mktime("2023 03 01 00 00 00"))
}
FILENAME == "social_insurances/r5ippan3.csv.tmp" {
  set_lib_si(mktime("2023 03 01 00 00 00"), mktime("2024 03 01 00 00 00"))
}
function set_lib_si(start_date, end_date) {
  lib_si[start_date][end_date][$1][$2][HEALTH_INSURANCE_ALL_lt40]  =$3
  lib_si[start_date][end_date][$1][$2][HEALTH_INSURANCE_HALF_lt40] =$4
  lib_si[start_date][end_date][$1][$2][HEALTH_INSURANCE_ALL_ge40]  =$5
  lib_si[start_date][end_date][$1][$2][HEALTH_INSURANCE_HALF_ge40] =$6
  lib_si[start_date][end_date][$1][$2][WELFARE_PENSION_ALL]        =$7
  lib_si[start_date][end_date][$1][$2][WELFARE_PENSION_HALF]       =$8
}

# 保険料率マスタ作成（子ども・子育て拠出金率追加）
#
FILENAME == "social_insurances/h30ippan4.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2018 04 01 00 00 00"), mktime("2019 03 01 00 00 00"))
}
FILENAME == "social_insurances/h31ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2019 03 01 00 00 00"), mktime("2019 04 01 00 00 00"))
}
FILENAME == "social_insurances/h310402.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2019 04 01 00 00 00"), mktime("2020 03 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2020 03 01 00 00 00"), mktime("2020 04 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan4.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2020 04 01 00 00 00"), mktime("2020 09 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan9.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2020 09 01 00 00 00"), mktime("2021 03 01 00 00 00"))
}
FILENAME == "social_insurances/r3ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2021 03 01 00 00 00"), mktime("2022 03 01 00 00 00"))
}
FILENAME == "social_insurances/r4ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2022 03 01 00 00 00"), mktime("2023 03 01 00 00 00"))
}
FILENAME == "social_insurances/r5ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  set_lib_si_child(mktime("2023 03 01 00 00 00"), mktime("2024 03 01 00 00 00"))
}
function set_lib_si_child(start_date, end_date) {
  cmn_debug_log("#set_lib_si_child, v($1)=" v($1))
  lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE] = v($1)
}
function v(value) {
  gsub(/[^0-9\.]*/, "", value)
  return value
}

ARGIND == ARGC - 1 && !iii++ {
  # 賃金台帳.csvの1行目を読み込んだとき
  # print $0  > "/dev/stderr"

  # BOMの削除（従業員名の配列が利用できなくなるのを防ぐ）
  sub("\xef\xbb\xbf", "", $0)
  # \r削除（子ども・子育て拠出金（会社）の計算ができなくなるのを防ぐ）
  sub("\r", "", $0)
  create_conv_lib($0)
}

# 利用項目
# col_to_idx["従業員名"]
# col_to_idx["従業員番号"]
# col_to_idx["種別"]
# col_to_idx["支給月日"]
# col_to_idx["給与計算締日（固定給）"]
# col_to_idx["生年月日"]
# col_to_idx["健康保険料"]
# col_to_idx["介護保険料"]
# col_to_idx["厚生年金保険料"]
# col_to_idx["社会保険料等控除合計"]
# col_to_idx["健康保険標準報酬月額"]
# col_to_idx["厚生年金保険標準報酬月額"]

function create_conv_lib(payroll_book_csv_header    , p, i, count, column_name, debug_idx) {
  split(payroll_book_csv_header, p, ",")

  #print ""  > "/dev/stderr"
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in p) {
    #print p[i]  > "/dev/stderr"
    if ($i) {
      col_to_idx[$i] = i
      # print col_to_idx[$i] ", " $i  > "/dev/stderr"
      idx_to_col[i] = $i
      count[$i]++
    } else {
      print i, p[i], "不正なCSVヘッダー項目nullがありました。"
      exit 1
    }
  }
  for (column_name in count) {
    if (count[column_name] > 1 && column_name != "\"\"") {
      print "賃金台帳のヘッダー項目に同名項目があり、計算齟齬が発生する場合があります。同名項目：" column_name
      exit 1
    }
  }

  if (v_debug_lfg) {
    for (debug_idx in use_idx) {
      cmn_debug_log("cmn_cut_col_from_payroll.awk#create_conv_lib: use_idx, col = " use_idx[debug_idx] ", " debug_idx)
    }
  }
}

# 払込が祝祭日のときは翌日営業日APIを起動
ARGIND == ARGC - 1 && $col_to_idx["種別"] == "給与" && !year[substr($col_to_idx["支給月日"], 1, 4)]++ {
  cmn_holiday_api(substr($col_to_idx["支給月日"], 1, 4))
}

# ARGIND（現在処理しているオプション以外の引数）
# ARGC - 1（コマンドを1, オプション以外の引数：ファイル数）
# ARGIND == ARGC - 1 で賃金台帳ファイルのときの条件となる
ARGIND == ARGC - 1 && $col_to_idx["種別"] == "給与" {
  set()
}

END {
  # BOM
  printf "\xEF\xBB\xBF"

  # HEAD
  print "収支区分,管理番号,発生日,決済期日,取引先コード,取引先,勘定科目,税区分,金額,税計算区分,税額,備考,品目,部門,メモタグ（複数指定可、カンマ区切り）,セグメント1,セグメント2,セグメント3,決済日,決済口座,決済金額"

  # ひどいループ、リファクタリングしたい
  for (day_base in social) {
    if (cmn_is_date(day_base)) {
      continue
    }
    for (day_sal in social[day_base]) {
      for (day_settlement in social[day_base][day_sal]) {
        for (employee in social[day_base][day_sal][day_settlement]) {
          i=0
          if (!i++) {
            printf "支出"
          }
          for (q in social[day_base][day_sal][day_settlement][employee]) {
            print social[day_base][day_sal][day_settlement][employee][q]
          }
        }
      }
    }
  }
}

function set(    insmap) {
  entry_date = cmn_to_mktime($col_to_idx["給与計算締日（固定給）"])
  use_lib_si(entry_date, insmap)

  for (remarks in insmap) {
    for (account in insmap[remarks]) {
      set_social(remarks, insmap[remarks][account], account)
    }
  }
}

function set_social(remarks, value, account    , pay_date, torihiki) {
  cmn_debug_log("set_social#remarks, value, account : " remarks ", " value ", " account)
  if (value) {
    entry_date = cmn_entry_strdate(remarks)
    pay_date = cmn_pay_insur_strdate($col_to_idx["支給月日"])

    # 要リファクタリング
    if (account == "預り金（社会保険）") {
      torihiki = "従業員"
    } else {
      torihiki = "社会保険・労働保険"
    }
    social[cmn_entry_strdate()][entry_date][pay_date][$col_to_idx["従業員番号"]][remarks]=",," entry_date "," pay_date ",," torihiki "," account ",対象外," value ",,," remarks "," remarks "," cmn_emp_name() ",\"import_社会保険料,社会保険料\",,,,,,"
  }
}

# 社会保険料（介護保険なし）従業員
function get_insur(lib_si, age, stat) {
  mount = cmn_roundoff(get_age_val_half(lib_si, age) - get_kaigo_ro(lib_si, age), stat)
  cmn_insra_chk_health(stat, mount)
  return mount
}
function get_age_val_half(lib_si, age) {
  if (age > 39) {
    return cmn_get_val(lib_si, HEALTH_INSURANCE_HALF_ge40)
  } else {
    return cmn_get_val(lib_si, HEALTH_INSURANCE_HALF_lt40)
  }
}
# 社会保険料（介護保険なし）会社
function get_insur_campany(lib_si, age, stat) {
  mount = int(get_age_val_all(lib_si, age)) - get_insur(lib_si, age, stat)
  return mount
}
function get_age_val_all(lib_si, age) {
  if (age > 39) {
    return cmn_get_val(lib_si, HEALTH_INSURANCE_ALL_ge40)
  } else {
    return cmn_get_val(lib_si, HEALTH_INSURANCE_ALL_lt40)
  }
}
# 社会保険料（介護保険あり）会社
function get_insur_campany_plus_kaigo(lib_si, age, stat) {
  mount = int(get_age_val_all(lib_si, age))
  return mount
}

function use_lib_si(entry_date, insmap,    age, start_date, end_date) {
  for (start_date in lib_si) {
    for (end_date in lib_si[start_date]) {
      if (entry_date >= start_date && entry_date < end_date) {
        age = cmn_age()
        cmn_debug_log("entry_date, age : " strftime("%Y/%m/%d %H:%M:%S",entry_date) ", " age)
        insmap["健康保険料（従業員）"]["預り金（社会保険）"]       = get_insur(lib_si[start_date][end_date], age, "employee")
        insmap["健康保険料（会社）"]["法定福利費"]     = get_insur_campany(lib_si[start_date][end_date], age, "owner")
        insmap["厚生年金保険料（従業員）"]["預り金（社会保険）"]   = get_plan3(lib_si[start_date][end_date], age, "employee")
        insmap["厚生年金保険料（会社）"]["法定福利費"] = get_plan3(lib_si[start_date][end_date], age, "owner")
        insmap["子ども・子育て拠出金（会社）"]["法定福利費"] = calc_child_care(start_date, end_date)
        if (age > 39) {
          cmn_debug_log("介護保険料条件内age : " age " " cmn_emp_name())
          insmap["介護保険料（従業員）"]["預り金（社会保険）"]     = get_kaigo_ro(lib_si[start_date][end_date], age)
          insmap["介護保険料（会社）"]["法定福利費"]   = insmap["介護保険料（従業員）"]["預り金（社会保険）"]
          # 上書き（要リファクタリング）
          insmap["健康保険料（会社）"]["法定福利費"] = get_insur_campany_plus_kaigo(lib_si[start_date][end_date], age, "owner") - get_insur(lib_si[start_date][end_date], age, "employee") - get_kaigo_ro(lib_si[start_date][end_date], age)*2
        }
      }
    }
  }
}

function get_kaigo_ro(lib_si, age) {
  mount = cmn_rounddown(get_kaigo_insur(lib_si, age))
  cmn_insra_chk_kaigo(mount)
  return mount
}

function get_kaigo_insur(lib_si, age) {
  if (age > 39) {
    # 介護保険料
    kaigo_insur = cmn_get_val(lib_si, HEALTH_INSURANCE_HALF_ge40) - cmn_get_val(lib_si, HEALTH_INSURANCE_HALF_lt40)
    return cmn_bigdecimal(kaigo_insur)
  }
  return 0
}

function get_plan3(lib_si, age, stat) {
  mount = cmn_roundoff(cmn_get_val(lib_si, WELFARE_PENSION_HALF), stat)
  cmn_insra_chk_welfare(stat, mount)
  return mount
}

function calc_child_care(start_date, end_date,    i) {
  cmn_debug_log("#calc_child_care: " strftime("%Y/%m/%d %H:%M:%S",start_date) ", " strftime("%Y/%m/%d %H:%M:%S",end_date))
  cmn_debug_log("#calc_child_care,  $col_to_idx[\"厚生年金保険標準報酬月額\"]=" $col_to_idx["厚生年金保険標準報酬月額"])
  i = (lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE] / 100) * $col_to_idx["厚生年金保険標準報酬月額"]
  cmn_debug_log("#calc_child_care, lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE]=" lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE])
  return int(cmn_bigdecimal(i))
}
