BEGIN {
  # 出力 csvのヘッダー
  # [その他の会計ソフトから仕訳データを移行する（弥生会計形式を用いた方法） – freee ヘルプセンター](https://support.freee.co.jp/hc/ja/articles/202847920?_ga=2.203703952.1268415934.1603067789-2047650957.1599020498)
  output_header_cols[1]  = "[表題行]"
  output_header_cols[2]  = "日付"
  output_header_cols[3]  = "伝票No."
  output_header_cols[4]  = "借方勘定科目"
  output_header_cols[5]  = "借方補助科目"
  output_header_cols[6]  = "借方部門"
  output_header_cols[7]  = "借方セグメント1"
  output_header_cols[8]  = "借方セグメント2"
  output_header_cols[9]  = "借方セグメント3"
  output_header_cols[10] = "借方税区分"
  output_header_cols[11] = "借方金額"
  output_header_cols[12] = "借方税額"
  output_header_cols[13] = "貸方勘定科目"
  output_header_cols[14] = "貸方補助科目"
  output_header_cols[15] = "貸方部門"
  output_header_cols[16] = "貸方セグメント1"
  output_header_cols[17] = "貸方セグメント2"
  output_header_cols[18] = "貸方セグメント3"
  output_header_cols[19] = "貸方税区分"
  output_header_cols[20] = "貸方金額"
  output_header_cols[21] = "貸方税額"
  output_header_cols[22] = "摘要"
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

$col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与" {
  set_tax_journals()
}

function set_tax_journals(    j1, j2, j3) {
  j1 = entry_date()
  j2 = work_in[$col_to_idx["従業員番号"]]
  j3 = col_to_idx["所得税"]
  journals[j1][j2][j3] += $col_to_idx["所得税"]
}

# 納期の特例支払期限
function entry_date(    yyyy, mm) {
  yyyy = substr($col_to_idx["支給月日"], 1, 4)
    mm = substr($col_to_idx["支給月日"], 6, 2)
  # 1~6月、7~8月判定
  if (int(mm/7)) {
    return yyyy + 1 "/01/01"
  } else {
    return yyyy "/07/01"
  }
}

$col_to_idx["種別"] == "給与" && $col_to_idx["年末調整精算"] {
  set_nomal_journals()
}

function set_nomal_journals(    j1, j2, j3) {
  j1 = $col_to_idx["支給月日"]
  j2 = work_in[$col_to_idx["従業員番号"]]
  j3 = col_to_idx["年末調整精算"]
  journals[j1][j2][j3] = $col_to_idx["年末調整精算"]
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

function print_data_csv(    j1, j2, j3) {
  PROCINFO["sorted_in"]="@ind_str_asc"
  # journalsループ
  for (j1 in journals) {
    for (j2 in journals[j1]) {
      for (j3 in journals[j1][j2]) {
        csv_output_csv_cols(j1, j2, j3)
      }
    }
  }
}

function csv_output_csv_cols(j1, j2, j3    , output_csv_cols) {
  _amount = journals[j1][j2][j3]
  # 所得税
  if (j3 == col_to_idx["所得税"]) {
    output_csv_cols[j3][_o("[表題行]")]     = "[明細行]"
    output_csv_cols[j3][_o("日付")]         = j1
    output_csv_cols[j3][_o("伝票No.")]      = ++j_count
    output_csv_cols[j3][_o("借方勘定科目")] = "預り金"
    output_csv_cols[j3][_o("借方補助科目")] = idx_to_col(j3)
    output_csv_cols[j3][_o("借方部門")]     = get_depertment(j2)
    output_csv_cols[j3][_o("借方税区分")]   = "対象外"
    output_csv_cols[j3][_o("借方金額")]     = _amount
    output_csv_cols[j3][_o("借方税額")]     = 0
    output_csv_cols[j3][_o("貸方勘定科目")] = "未払金"
    output_csv_cols[j3][_o("貸方補助科目")] = idx_to_col(j3)
    output_csv_cols[j3][_o("貸方部門")]     = get_depertment(j2)
    output_csv_cols[j3][_o("貸方税区分")]   = "対象外"
    output_csv_cols[j3][_o("貸方金額")]     = _amount
    output_csv_cols[j3][_o("貸方税額")]     = 0
    output_csv_cols[j3][_o("摘要")]         = remarks(j1, get_depertment(j2))
  }

  # 年末調整精算
  if (j3 == col_to_idx["年末調整精算"]) {
    output_csv_cols[j3][_o("[表題行]")]     = "[明細行]"
    output_csv_cols[j3][_o("日付")]         = j1
    output_csv_cols[j3][_o("伝票No.")]      = ++j_count
    output_csv_cols[j3][_o("借方勘定科目")] = get_journal(_amount, _o("借方勘定科目"))
    output_csv_cols[j3][_o("借方補助科目")] = idx_to_col(j3)
    output_csv_cols[j3][_o("借方部門")]     = get_depertment(j2)
    output_csv_cols[j3][_o("借方税区分")]   = "対象外"
    output_csv_cols[j3][_o("借方金額")]     = abs(_amount)
    output_csv_cols[j3][_o("借方税額")]     = 0
    output_csv_cols[j3][_o("貸方勘定科目")] = get_journal(_amount, _o("貸方勘定科目"))
    output_csv_cols[j3][_o("貸方補助科目")] = idx_to_col(j3)
    output_csv_cols[j3][_o("貸方部門")]     = get_depertment(j2)
    output_csv_cols[j3][_o("貸方税区分")]   = "対象外"
    output_csv_cols[j3][_o("貸方金額")]     = abs(_amount)
    output_csv_cols[j3][_o("貸方税額")]     = 0
    output_csv_cols[j3][_o("摘要")]         = remarks(j1, get_depertment(j2))
  }
  print_output_csv_cols(output_csv_cols, j3)
}

function _o(col) {
  return _output_header_cols[col]
}

function get_journal(amount, account) {
    if (amount > 0 && account == _o("借方勘定科目")) {
      return "預り金"
    }
    if (amount > 0 && account == _o("貸方勘定科目")) {
      return "未払金"
    }
    if (amount < 0 && account == _o("借方勘定科目")) {
      return "未払金"
    }
    if (amount < 0 && account == _o("貸方勘定科目")) {
      return "預り金"
    }
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

function remarks(entry_date, depertment    , yyyy, mm) {
  yyyy = substr(entry_date, 1, 4)
    mm = substr(entry_date, 6, 2)
  return "【所得税】【" depertment "】" yyyy "年" mm "月支払い給与"
}

function tags(entry_date) {
  yyyy = substr(entry_date, 1, 4)
    mm = substr(entry_date, 6, 2)
  # 1~6月、7~8月判定
  if (int(mm/7)) {
    return "納特1月"
  } else {
    return "納特7月"
  }
}

function print_output_csv_cols(output_csv_cols, journal    , i, col, str_cols, count) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in output_header_cols) {
    if (i in output_csv_cols[journal]) {
      col = csv_comma(count) output_csv_cols[journal][i]
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
