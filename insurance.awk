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
  set_lib_si(mktime("2020 04 01 00 00 00"), mktime("2021 03 01 00 00 00"))
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
  cmn_debug_log("social_insurances/h30ippan4.csv : " $1)
  set_lib_si_child(mktime("2018 04 01 00 00 00"), mktime("2019 03 01 00 00 00"))
}
FILENAME == "social_insurances/h31ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h31ippan3.csv : " $1)
  set_lib_si_child(mktime("2019 03 01 00 00 00"), mktime("2019 04 01 00 00 00"))
}
FILENAME == "social_insurances/h310402.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h310402.csv : " $1)
  set_lib_si_child(mktime("2019 04 01 00 00 00"), mktime("2020 03 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h310402.csv : " $1)
  set_lib_si_child(mktime("2020 03 01 00 00 00"), mktime("2020 04 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan4.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h310402.csv : " $1)
  set_lib_si_child(mktime("2020 04 01 00 00 00"), mktime("2021 03 01 00 00 00"))
}
function set_lib_si_child(start_date, end_date) {
  cmn_debug_log("#set_lib_si_child, v($1)=" v($1))
  lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE] = v($1)
}
function v(value) {
  gsub(/[^0-9\.]*/, "", value)
  return value
}

ARGIND == ARGC - 1 && $5 == "給与" {
  cmn_debug_log("$5 == \"給与\"")
  set()
}
END {
  # BOM
  printf "\xEF\xBB\xBF"

  # HEAD
  print "収支区分,管理番号,発生日,決済期日,取引先コード,取引先,勘定科目,税区分,金額,税計算区分,税額,備考,品目,部門,メモタグ（複数指定可、カンマ区切り）,セグメント1,セグメント2,セグメント3,決済日,決済口座,決済金額"

  for (day_sal in social) {
    if (cmn_is_date(day_sal)) {
      continue
    }
    for (employee in social[day_sal]) {
      i=0
      if (!i++) {
        printf "支出"
      }
      for (q in social[day_sal][employee]) {
        print social[day_sal][employee][q]
      }
    }
  }
}

function set(    insmap) {
  entry_date = cmn_to_mktime($9)
  use_lib_si(entry_date, insmap)

  for (remarks in insmap) {
    for (account in insmap[remarks]) {
      set_social(remarks, insmap[remarks][account], account)
    }
  }
}

function set_social(remarks, value, account) {
  cmn_debug_log("set_social#remarks, value, account : " remarks ", " value ", " account)
  if (value) {
    social[cmn_entry_strdate()][$2][remarks]=",," cmn_entry_strdate() "," $7 ",," cmn_emp_name() "," account ",対象外," value ",,," remarks "," remarks "," cmn_emp_name() ",\"import_社会保険料,社会保険料\",,,,,,"
  }
}

# 社会保険料（介護保険なし）
function get_insur(lib_si, age, stat) {
  mount = cmn_roundoff(get_age_val(lib_si, age) - get_kaigo_ro(lib_si, age), stat)
  cmn_insra_chk_health(stat, mount)
  return mount
}
function get_age_val(lib_si, age) {
  if (age > 39) {
    return cmn_get_val(lib_si, HEALTH_INSURANCE_HALF_ge40)
  } else {
    return cmn_get_val(lib_si, HEALTH_INSURANCE_HALF_lt40)
  }
}

function use_lib_si(entry_date, insmap,    age, start_date, end_date) {
  for (start_date in lib_si) {
    for (end_date in lib_si[start_date]) {
      if (entry_date >= start_date && entry_date < end_date) {
        age = cmn_age()
        cmn_debug_log("entry_date, age : " entry_date ", " age)
        insmap["健康保険料（従業員）"]["預り金"]       = get_insur(lib_si[start_date][end_date], age, "employee")
        insmap["健康保険料（会社）"]["法定福利費"]     = get_insur(lib_si[start_date][end_date], age, "owner")
        insmap["厚生年金保険料（従業員）"]["預り金"]   = get_plan3(lib_si[start_date][end_date], age, "employee")
        insmap["厚生年金保険料（会社）"]["法定福利費"] = get_plan3(lib_si[start_date][end_date], age, "owner")
        insmap["子ども・子育て拠出金（会社）"]["法定福利費"] = calc_child_care(start_date, end_date)
        if (age > 39) {
          cmn_debug_log("介護保険料条件内age : " age " " cmn_emp_name())
          insmap["介護保険料（従業員）"]["預り金"]     = get_kaigo_ro(lib_si[start_date][end_date], age)
          insmap["介護保険料（会社）"]["法定福利費"]   = insmap["介護保険料（従業員）"]["預り金"]
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
  cmn_debug_log("#calc_child_care,  $77=" $77)
  i = (lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE] / 100) * $77
  cmn_debug_log("#calc_child_care, lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE]=" lib_si_child[start_date][end_date][CHILD_CARE_PERCENTAGE])
  return int(cmn_bigdecimal(i))
}
