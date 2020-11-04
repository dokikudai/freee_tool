BEGIN {
  # 出力 csvのヘッダー
  # [取引・口座振替のインポート（一括登録） – freee ヘルプセンター](https://support.freee.co.jp/hc/ja/articles/202847320-%E5%8F%96%E5%BC%95-%E5%8F%A3%E5%BA%A7%E6%8C%AF%E6%9B%BF%E3%81%AE%E3%82%A4%E3%83%B3%E3%83%9D%E3%83%BC%E3%83%88-%E4%B8%80%E6%8B%AC%E7%99%BB%E9%8C%B2-)
  output_header_cols[1]  = "収支区分"
  output_header_cols[2]  = "管理番号"
  output_header_cols[3]  = "発生日"
  output_header_cols[4]  = "決済期日"
  output_header_cols[5]  = "取引先コード"
  output_header_cols[6]  = "取引先"
  output_header_cols[7]  = "勘定科目"
  output_header_cols[8]  = "税区分"
  output_header_cols[9]  = "金額"
  output_header_cols[10] = "税計算区分"
  output_header_cols[11] = "税額"
  output_header_cols[12] = "備考"
  output_header_cols[13] = "品目"
  output_header_cols[14] = "部門"
  output_header_cols[15] = "メモタグ（複数指定可、カンマ区切り）"
  output_header_cols[16] = "セグメント1"
  output_header_cols[17] = "セグメント2"
  output_header_cols[18] = "セグメント3"
  output_header_cols[19] = "決済日"
  output_header_cols[20] = "決済口座"
  output_header_cols[21] = "決済金額"
  v_to_k_output_header_cols()
}

function v_to_k_output_header_cols(    k) {
  for (k in output_header_cols) {
    _output_header_cols[output_header_cols[k]] = k
  }
}

# 賃金台帳の項目名から index に変換の連想配列を作成
# 例えば、 $col_to_idx["従業員名"] で $1 と同様の結果が得られる
NR == 1 {
  create_conv_lib($0)
}

function create_conv_lib(payroll_book_csv_header    , p, i, count, column_name) {
  split(payroll_book_csv_header, p, ",")

  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in p) {
    if ($i) {
      col_to_idx[$i] = i
      count[$i]
    } else {
      print "不正なCSVヘッダー項目nullがありました。"
      exit 1
    }
  }
  for (column_name in count) {
    if (count[column_name] > 1) {
      print "賃金台帳のヘッダー項目に同名項目があり、計算齟齬が発生する場合があります。同名項目：" column_name
      exit 1
    }
  }
}

($col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与") && $col_to_idx["雇用保険料"] {
  set_nomal_journals()
}

function set_nomal_journals(    j1, j2, j3) {
  j1 = $col_to_idx["種別"]
  if ($col_to_idx["種別"] == "賞与") {
    j2 = cmn_bounus_entry_strdate()
  }
  if ($col_to_idx["種別"] == "給与") {
    j2 = $col_to_idx["給与計算締日（固定給）"]
  }
  j3 = work_in[$col_to_idx["従業員番号"]]
  journals[j1][j2][j3] = $col_to_idx["総支給額"] "," $col_to_idx["雇用保険料"]

  # 休日API利用
  if (!cmn_holiday_api_count++) {
    cmn_holiday_api(substr(pay_date(j2), 1, 4))
  }
}

END {
  # BOM
  printf "\xEF\xBB\xBF"

  print_header_csv(output_header_cols)
  print_data_csv()
}

function print_header_csv(cols    , i, col, str_cols, count) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in cols) {
    str_cols = str_cols csv_comma(count) cols[i]
  }
  print str_cols
}

function print_data_csv(    j1) {
  PROCINFO["sorted_in"]="@ind_str_asc"
  # journalsループ
  for (j1 in journals) {
    output_csv_owner(journals[j1], j1)
    set_csv_emplyee(journals[j1], j1)
  }
}

function output_csv_owner(journals_j1, j1    , j2, j3) {
  for (j2 in journals_j1) {
    if (cmn_is_date(j2)) {
      continue
    }
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
  output_csv_cols[_o("発生日")]    = j2
  output_csv_cols[_o("決済期日")]  = pay_date(j2)
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "法定福利費"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = round_half_up(_amount[1] * 6 / 1000)
  output_csv_cols[_o("備考")]      = remarks(j2, j1)
  output_csv_cols[_o("品目")]      = "雇用保険（事業主）"
  output_csv_cols[_o("部門")]      = cmn_emp_name()
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags(j1)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_2(j1, j2, j3    , _amount, output_csv_cols) {
  split(journals[j1][j2][j3], _amount, ",")
  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j2
  output_csv_cols[_o("決済期日")]  = pay_date(j2)
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "法定福利費"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = round_half_up(_amount[1] * 3 / 1000)
  output_csv_cols[_o("備考")]      = remarks(j2, j1)
  output_csv_cols[_o("品目")]      = "労災保険（事業主）"
  output_csv_cols[_o("部門")]      = cmn_emp_name()
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags(j1)
  print_output_csv_cols(output_csv_cols)
}

function output_csv_owner_3(j1, j2, j3    , _amount, output_csv_cols) {
  split(journals[j1][j2][j3], _amount, ",")
  output_csv_cols[_o("収支区分")]  = ""
  output_csv_cols[_o("発生日")]    = j2
  output_csv_cols[_o("決済期日")]  = pay_date(j2)
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "法定福利費"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = int(_amount[1] * 0.02 / 1000)
  output_csv_cols[_o("備考")]      = remarks(j2, j1)
  output_csv_cols[_o("品目")]      = "一般拠出金（事業主）"
  output_csv_cols[_o("部門")]      = cmn_emp_name()
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags(j1)
  print_output_csv_cols(output_csv_cols)
}

function set_csv_emplyee(journals_j1, j1    , j2, j3, counter) {
  for (j2 in journals_j1) {
    if (cmn_is_date(j2)) {
      continue
    }
    for (j3 in journals_j1[j2]) {
      set_csv_emplyee_1(j1, j2, j3, counter[pay_date(j2)]++)
    }
  }
}

function set_csv_emplyee_1(j1, j2, j3, c    , _amount, output_csv_cols) {
  split(journals[j1][j2][j3], _amount, ",")
  output_csv_cols[_o("収支区分")]  = output_csv_emplyee1_bp(c)
  output_csv_cols[_o("発生日")]    = pay_date(j2)
  output_csv_cols[_o("決済期日")]  = pay_date(j2)
  output_csv_cols[_o("取引先")]    = "従業員"
  output_csv_cols[_o("勘定科目")]  = "預り金（労働保険）"
  output_csv_cols[_o("税区分")]    = "対象外"
  output_csv_cols[_o("金額")]      = in_over5(_amount[1] * 3 / 1000)
  output_csv_cols[_o("備考")]      = remarks(j2, j1)
  output_csv_cols[_o("品目")]      = "雇用保険料（従業員）"
  output_csv_cols[_o("部門")]      = cmn_emp_name()
  output_csv_cols[_o("メモタグ（複数指定可、カンマ区切り）")] = tags(j1)
  if (output_csv_cols[_o("金額")] == _amount[2]) {
    print_output_csv_cols(output_csv_cols)
  } else {
    print "freee賃金台帳と雇用保険料（従業員）の金額があっていません。"
    exit 1
  }
}

function _o(col) {
  return _output_header_cols[col]
}

function output_csv_emplyee1_bp(c) {
  if (c) {
    return "" 
  } else {
    return "支出"
  }
}

function pay_date(date) {
  yyyy = substr(date, 1, 4)
    mm = substr(date, 6, 2)
  if (mm ~ /0[123]/ ) {
    return cmn_pay_insur_strdate(yyyy "/07/10")
  } else {
    return cmn_pay_insur_strdate(yyyy+1 "/07/10")
  }
}

function remarks(j2, j1) {
  return pay_date(j2) "納付期限、労働保険料、" j2 "締め" j1 "）"
}

function tags(j1) {
  return "\"" "import_労働保険,労働保険," j1 "\""
}

function abs(amount) {
    if (_amount < 0) {
      return -1 * _amount 
    } else {
      return amount
    }
}

function idx_to_col(idx) {
  for (journal in col_to_idx) {
    if (idx == col_to_idx[journal]) {
      return journal
    }
  }
}

function print_output_csv_cols(output_csv_cols    , i, col, str_cols, count) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in output_header_cols) {
    if (i in output_csv_cols) {
      col = csv_comma(count) output_csv_cols[i]
    } else {
      col = csv_comma(count)
    }
    str_cols = str_cols col
  }
  print str_cols
}

function csv_comma(count) {
  if (count["one"]++) {
    return ","
  }
}
