($col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与") && $col_to_idx["雇用保険料"] {
  set_nomal_journals()
}

function set_nomal_journals(    j1, j2, j3) {
  if ($col_to_idx["種別"] == "賞与") {
    j1 = _cmn_bounus_entry_date($col_to_idx["支給月日"])
  }
  if ($col_to_idx["種別"] == "給与") {
    j1 = $col_to_idx["給与計算締日（固定給）"]
  }
  j2 = work_in[$col_to_idx["従業員番号"]]
  j3 = $col_to_idx["種別"]
  journals[j1][j2][j3] = $col_to_idx["総支給額"] "," $col_to_idx["雇用保険料"]
}

function output_csv_owner(journals_j1, j1    , j2, j3) {
  for (j2 in journals_j1) {
    for (j3 in journals_j1[j2]) {
      output_csv_owner_1(j1, j2, j3)
      output_csv_owner_2(j1, j2, j3)
      output_csv_owner_3(j1, j2, j3)
    }
  }
}

function output_csv_owner_1(j1, j2, j3    , _amount, output_csv_cols) {
  split(journals[j1][j2][j3], _amount, ",")
  output_csv_cols[_o("収支区分")]  = "支出"
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = pay_date(j1)
  output_csv_cols[_o("取引先")]    = "社会保険・労働保険"
  output_csv_cols[_o("勘定科目")]  = "法定福利費（労働保険）" odd_or_even(j1)
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = round_half_up(_amount[1] * 9 / 1000)
  output_csv_cols[_o("備考")]      = remarks(j1, j3)
  output_csv_cols[_o("品目")]      = "労働保険（会社）"
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags(j1, j3)
  print_output_csv_cols(output_csv_cols)

  labor_insurance_sum["労働保険（会社）"] += output_csv_cols[_o("金額")]
}

function output_csv_owner_2(j1, j2, j3    , _amount, output_csv_cols) {
  split(journals[j1][j2][j3], _amount, ",")
  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = pay_date(j1)
  output_csv_cols[_o("取引先")]    = "社会保険・労働保険"
  output_csv_cols[_o("勘定科目")]  = "未払費用（労働保険）" odd_or_even(j1)
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = -1 * round_half_up(_amount[1] * 9 / 1000)
  output_csv_cols[_o("備考")]      = remarks(j1, j3)
  output_csv_cols[_o("品目")]      = "労働保険（会社）"
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags(j1, j3)
  print_output_csv_cols(output_csv_cols)

  labor_insurance_sum["労災保険（会社）"] += output_csv_cols[_o("金額")]
}

function output_csv_owner_3(j1, j2, j3    , _amount, output_csv_cols) {
  split(journals[j1][j2][j3], _amount, ",")
  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j1
  output_csv_cols[_o("決済期日")]  = pay_date(j1)
  output_csv_cols[_o("取引先")]    = "社会保険・労働保険"
  output_csv_cols[_o("勘定科目")]  = "法定福利費（労働保険）" odd_or_even(j1)
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = int(_amount[1] * 0.02 / 1000)
  output_csv_cols[_o("備考")]      = remarks(j1, j3)
  output_csv_cols[_o("品目")]      = "一般拠出（会社）"
  output_csv_cols[_o("部門")]      = get_depertment(j2)
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags(j1, j3)
  print_output_csv_cols(output_csv_cols)

  labor_insurance_sum["一般拠出（会社）"] += output_csv_cols[_o("金額")]
}

function print_labor_insurance_sum(    i) {
  for (i in labor_insurance_sum) {
    print i, labor_insurance_sum[i]
  }
}

function odd_or_even(strdate,    d) {
  split(strdate, d , "/")
  if (d[1] % 2 && d[2] ~ /0[1-3]/) {
    return "偶"
  }
  if (d[1] % 2) {
    return "奇"
  }
  if (d[2] ~ /0[1-3]/) {
    return "奇"
  }
  return "偶"
}

function remarks(j1, j3) {
  return ""
}

function tags(j1, j3) {
  return DQ "import_労働保険,労働保険," substr(j1,6,5) "締め" j3 DQ
}
