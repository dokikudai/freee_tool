BEGIN {
  PROCINFO["sorted_in"]="@ind_str_asc"
  HEALTH_INSURANCE_PERCENTAGE_lt40  = "健康保険料率（39歳以下）"
  HEALTH_INSURANCE_PERCENTAGE_ge40  = "健康保険料率（40歳以上）"
  WELFARE_PENSION_PERCENTAGE        = "厚生年金保険料率"
  CHILD_CARE_PERCENTAGE             = "子ども・子育て拠出金率"

  MAX_MONTH_BOUNUS_OR_CHILD_MOUNT   = 1500000
}


# 保険料率マスタ作成
#
FILENAME == "social_insurances/h30ippan4.csv" && FNR == 11 {
  set_lib_si_bounus(mktime("2018 04 01 00 00 00"), mktime("2019 03 01 00 00 00"))
}
FILENAME == "social_insurances/h31ippan3.csv" && FNR == 11 {
  set_lib_si_bounus(mktime("2019 03 01 00 00 00"), mktime("2019 04 01 00 00 00"))
}
FILENAME == "social_insurances/h310402.csv" && FNR == 11 {
  cmn_debug_log("social_insurances/h310402.csv")
  set_lib_si_bounus(mktime("2019 04 01 00 00 00"), mktime("2020 03 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan3.csv" && FNR == 11 {
  cmn_debug_log("social_insurances/r2ippan3.csv")
  set_lib_si_bounus(mktime("2020 03 01 00 00 00"), mktime("2020 04 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan4.csv" && FNR == 11 {
  cmn_debug_log("social_insurances/r2ippan4.csv")
  set_lib_si_bounus(mktime("2020 04 01 00 00 00"), mktime("2021 03 01 00 00 00"))
}
function set_lib_si_bounus(start_date, end_date,    i) {
  cmn_debug_log("$0 = " $0)
  cmn_debug_log("$6 $8 $10 = " $6" "$8" "$10)
  cmn_debug_log("v($6) v($8) v($10) = " v($6)" "v($8)" "v($10))
  lib_si_bounus[start_date][end_date][HEALTH_INSURANCE_PERCENTAGE_lt40] = v($6)
  lib_si_bounus[start_date][end_date][HEALTH_INSURANCE_PERCENTAGE_ge40] = v($8)
  lib_si_bounus[start_date][end_date][WELFARE_PENSION_PERCENTAGE]       = v($10)
}
function v(value) {
  gsub(/[^0-9\.]*/, "", value)
  return value
}


# 保険料率マスタ作成（子ども・子育て拠出金率追加）
#
FILENAME == "social_insurances/h30ippan4.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h30ippan4.csv : " $1)
  set_lib_si_child_bounus(mktime("2018 04 01 00 00 00"), mktime("2019 03 01 00 00 00"))
}
FILENAME == "social_insurances/h31ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h31ippan3.csv : " $1)
  set_lib_si_child_bounus(mktime("2019 03 01 00 00 00"), mktime("2019 04 01 00 00 00"))
}
FILENAME == "social_insurances/h310402.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h310402.csv : " $1)
  set_lib_si_child_bounus(mktime("2019 04 01 00 00 00"), mktime("2020 03 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan3.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h310402.csv : " $1)
  set_lib_si_child_bounus(mktime("2020 03 01 00 00 00"), mktime("2020 04 01 00 00 00"))
}
FILENAME == "social_insurances/r2ippan4.csv" && $1 ~ /この子ども・子育て拠出金の額は、/ {
  cmn_debug_log("social_insurances/h310402.csv : " $1)
  set_lib_si_child_bounus(mktime("2020 04 01 00 00 00"), mktime("2021 03 01 00 00 00"))
}
function set_lib_si_child_bounus(start_date, end_date) {
  lib_si_bounus[start_date][end_date][CHILD_CARE_PERCENTAGE] = v($1)
}

# メイン
#
ARGIND == ARGC - 1 && $5 == "賞与" && $41 {
  set_bounus()
}

END {
  # BOM
  printf "\xEF\xBB\xBF"

  # HEAD
  print "収支区分,管理番号,発生日,決済期日,取引先コード,取引先,勘定科目,税区分,金額,税計算区分,税額,備考,品目,部門,メモタグ（複数指定可、カンマ区切り）,セグメント1,セグメント2,セグメント3,決済日,決済口座,決済金額"

  for (day_sal in social_bounus) {
    if (cmn_is_date(day_sal)) {
      continue
    }
    for (day_settlement in social_bounus[day_sal]) {
      for (employee in social_bounus[day_sal][day_settlement]) {
        i=0
        if (!i++) {
          printf "支出"
        }
        for (q in social_bounus[day_sal][day_settlement][employee]) {
          print social_bounus[day_sal][day_settlement][employee][q]
        }
      }
    }
  }
}

function set_bounus(    insmap_bonus) {
  cmn_debug_log("set_bounus")
  use_lib_si_bounus(insmap_bonus)
  for (remarks in insmap_bonus) {
    for (account in insmap_bonus[remarks]) {
      set_social_bounus(remarks, insmap_bonus[remarks][account], account)
    }
  }
}

function calc_bounus(value) {
  return int(value / 1000) * 1000
}

function set_social_bounus(remarks, value, account) {
  if (value) {
    social_bounus[cmn_bounus_entry_strdate(remarks)][$7][$2][remarks]=",," cmn_bounus_entry_strdate(remarks) "," $7 ",," cmn_emp_name() "," account ",対象外," value ",,," remarks "," remarks "," cmn_emp_name() ",\"import_社会保険料,社会保険料\",,,,,,"
  }
}

# 社会保険料（介護保険なし）
function calc_health_insurance(lib_si, age, stat,    i) {
  i = get_age_val_bounus(lib_si, age) - calc_long_term_care(lib_si, age)
  mount = cmn_roundoff(i, stat)
  cmn_insra_chk_health(stat, mount)
  return mount
}
function get_age_val_bounus(lib_si_bounus, age,    i) {
  if (age > 39) {
    cmn_debug_log("lib_si_bounus[HEALTH_INSURANCE_PERCENTAGE_ge40] = "lib_si_bounus[HEALTH_INSURANCE_PERCENTAGE_ge40])
    cmn_debug_log("lib_si_bounus[HEALTH_INSURANCE_PERCENTAGE_lt40] = "lib_si_bounus[HEALTH_INSURANCE_PERCENTAGE_lt40])
    i = (lib_si_bounus[HEALTH_INSURANCE_PERCENTAGE_ge40] / 100) * calc_bounus($41)
    cmn_debug_log("i = " i)
    cmn_debug_log("cmn_bigdecimal(i) = " cmn_bigdecimal(i))
    return cmn_bigdecimal(i / 2)
  } else {
    i = (lib_si_bounus[HEALTH_INSURANCE_PERCENTAGE_lt40] / 100) * calc_bounus($41)
    return cmn_bigdecimal(i / 2)
  }
}

function calc_long_term_care(lib_si_bounus, age) {
  mount = cmn_rounddown(get_kaigo_insur_bounus(lib_si_bounus, age))
  cmn_debug_log("calc_long_term_care.mount = " mount)
  cmn_insra_chk_kaigo(mount)
  return mount
}

function get_kaigo_insur_bounus(lib_si_bounus, age,    i) {
  if (age > 39) {
    # 介護保険料
    i = get_age_val_bounus(lib_si_bounus, age) - get_age_val_bounus(lib_si_bounus, 39)
    return cmn_bigdecimal(i)
  }
  return 0
}

function use_lib_si_bounus(insmap_bonus,    start_date, end_date, age) {
  pay_month = cmn_to_mktime($7)
  age = cmn_age()
  for (start_date in lib_si_bounus) {
    for (end_date in lib_si_bounus[start_date]) {
      cmn_debug_log("use_lib_si_bounus,= " start_date ", end_date = " end_date ", pay_month = " pay_month)
      if (pay_month >= start_date && pay_month < end_date) {
        insmap_bonus["健康保険料（従業員）"]["預り金"]             = calc_health_insurance(lib_si_bounus[start_date][end_date], age, "employee")
        insmap_bonus["健康保険料（会社）"]["法定福利費"]           = calc_health_insurance(lib_si_bounus[start_date][end_date], age, "owner")
        if (age > 39) {
          insmap_bonus["介護保険料（従業員）"]["預り金"]           = calc_long_term_care(lib_si_bounus[start_date][end_date], age)
          insmap_bonus["介護保険料（会社）"]["法定福利費"]         = insmap_bonus["介護保険料（従業員）"]["預り金"]
        }
        insmap_bonus["厚生年金保険料（従業員）"]["預り金"]         = calc_welfare_pension(lib_si_bounus[start_date][end_date], "employee")
        insmap_bonus["厚生年金保険料（会社）"]["法定福利費"]       = calc_welfare_pension(lib_si_bounus[start_date][end_date], "owner")
        insmap_bonus["子ども・子育て拠出金（会社）"]["法定福利費"] = calc_child_care(lib_si_bounus[start_date][end_date])
      }
    }
  }
}

function calc_welfare_pension(lib_si_bounus, stat,    i) {
  if ($41 > MAX_MONTH_BOUNUS_OR_CHILD_MOUNT) {
    $41 = MAX_MONTH_BOUNUS_OR_CHILD_MOUNT
  }
  i = (lib_si_bounus[WELFARE_PENSION_PERCENTAGE] / 100) * calc_bounus($41)
  mount = cmn_roundoff(cmn_bigdecimal(i / 2), stat)
  cmn_insra_chk_welfare(stat, mount)
  return mount
}

function calc_child_care(lib_si_bounus,    i) {
  if ($41 > MAX_MONTH_BOUNUS_OR_CHILD_MOUNT) {
    $41 = MAX_MONTH_BOUNUS_OR_CHILD_MOUNT
  }
  i = (lib_si_bounus[CHILD_CARE_PERCENTAGE] / 100) * calc_bounus($41)
  cmn_debug_log("(lib_si_bounus[CHILD_CARE_PERCENTAGE] / 100) * calc_bounus($41) = " i)
  return int(cmn_bigdecimal(i))
}
