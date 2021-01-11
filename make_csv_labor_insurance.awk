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
  output_csv_cols[_o("品目")]      = "労災保険（会社）"
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
