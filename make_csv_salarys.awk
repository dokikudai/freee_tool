$col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与" {
  set_nomal_journals()
}

# 従業員番号,種別,支給月日,給与計算締日（固定給）,基本給,賞与,健康保険料,介護保険料,厚生年金保険料,雇用保険料,住民税,所得税,非課税通勤手当,調整(精算済み),調整(精算待ち),天引き
#function create(    use_col_strings, use_vals, idx) {
#  use_col_strings = "支給月日,基本給,賞与,健康保険料,介護保険料,厚生年金保険料,雇用保険料,住民税,所得税,非課税通勤手当,調整(精算済み),調整(精算待ち),天引き"
#  sprit(use_col_strings, use_vals, ",")
#  for (idx in use_vals) {
#    vals_salary[use_vals[idx]] = idx
#  }
#}

function set_nomal_journals(    j1, j2, j3) {
  if ($col_to_idx["種別"] == "賞与") {
    j1 = _cmn_bounus_entry_date($col_to_idx["支給月日"])
  }
  if ($col_to_idx["種別"] == "給与") {
    j1 = $col_to_idx["給与計算締日（固定給）"]
  }
  j2 = work_in[$col_to_idx["従業員番号"]]
  j3 = $col_to_idx["種別"]
  journals[j1][j2][j3] = $0
}

function output_csv_owner(journals_j1, j1    , j2, j3) {
  for (j2 in journals_j1) {
    for (j3 in journals_j1[j2]) {
      output_csv_owner_1(j1, j2, j3)
      output_csv_owner_2(j1, j2, j3)
      output_csv_owner_3(j1, j2, j3)
      output_csv_owner_4(j1, j2, j3)
      output_csv_owner_5(j1, j2, j3)
      output_csv_owner_6(j1, j2, j3)
      output_csv_owner_7(j1, j2, j3)
      output_csv_owner_8(j1, j2, j3)
      output_csv_owner_9(j1, j2, j3)
      output_csv_owner_10(j1, j2, j3)
      output_csv_owner_11(j1, j2, j3)
    }
  }
}

function output_csv_owner_1(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!get_salary_amount()) {
    return
  }

  output_csv_cols[_o("収支区分")]  = "支出"
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = get_sal_account($col_to_idx["従業員番号"])
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = get_salary_amount()
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = ""
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function get_salary_amount() {
  if ($col_to_idx["種別"] == "給与") {
    return $col_to_idx["基本給"]
  }
  if ($col_to_idx["種別"] == "賞与") {
    return $col_to_idx["賞与"]
  }
  print "ERROR: #get_salary_amount" > "/dev/stderr"
  exit 1
}

function get_sal_account(emp_no) {
  # プロパティ的な設定として要改修
  if (emp_no ~ /[12]/) {
      return "役員報酬"
  }
  return "給料賃金"
}

function output_csv_owner_2(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["住民税"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（住民税）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["住民税"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = ""
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_3(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["健康保険料"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（社会保険）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["健康保険料"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = "健康保険料（従業員）"
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_4(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["介護保険料"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（社会保険）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["介護保険料"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = "介護保険料（従業員）"
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_5(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["厚生年金保険料"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（社会保険）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["厚生年金保険料"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = "厚生年金保険料（従業員）"
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_6(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["雇用保険料"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（労働保険）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["雇用保険料"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = "雇用保険料（従業員）"
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_7(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["所得税"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（従業員源泉徴収税）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["所得税"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = get_labor_item(j1)
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function get_labor_item(date    , tmp) {
  split(date, tmp, "/")
  if (tmp[2] ~ /0[1-5]/ || tmp[2] == "12") {
    return "12～05月"
  }
  if (tmp[2] ~ /0[6-9]/ || tmp[2] ~ /1[01]/) {
    return "06～11月"
  }
  print "ERROR: #get_labor_item" > "/dev/stderr"
  exit 1
}

function output_csv_owner_8(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["非課税通勤手当"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "通勤手当"
  output_csv_cols[_o("税区分")]    = "課対仕入10%"
  output_csv_cols[_o("金額")]      = $col_to_idx["非課税通勤手当"]
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = ""
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_9(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["調整(精算済み)"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "給料調整（預り金）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["調整(精算済み)"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = ""
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_10(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["調整(精算待ち)"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "給料調整（預り金）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["調整(精算待ち)"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = ""
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_11(j1, j2, j3    , output_csv_cols) {
  $0 = journals[j1][j2][j3]

  if (!$col_to_idx["天引き"]) {
    return
  }

  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = $col_to_idx["支給月日"]
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（天引）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = $col_to_idx["天引き"] * -1
  output_csv_cols[_o("備考")]      = ""
  output_csv_cols[_o("品目")]      = ""
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags($col_to_idx["支給月日"], j3)
  print_output_csv_cols(output_csv_cols)
}

function remarks(j1, j3) {
  return ""
}

function tags(j1, j3) {
  return DQ substr(j1,6,5) "支払" j3 ",import_給与" DQ
}
