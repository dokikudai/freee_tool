# 賃金台帳の項目名から index に変換の連想配列を作成
# 例えば、 $col_to_idx["従業員名"] で $1 と同様の結果が得られる
NR == 1 {
  create_conv_lib($0)
}

function create_conv_lib(payroll_book_csv_header    , p, i, count, column_name, idx) {
  split(payroll_book_csv_header, p, ",")

  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in p) {
    if ($i) {
      col_to_idx[$i] = i
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
  cmn_lib_use_idx(v_use_idx)
}

($col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与") && $col_to_idx["雇用保険料"] {
  set_data()
}

function set_data(    i, d, count) {
  if (cmn_is_date($col_to_idx["給与計算締日（固定給）"])) {
    return
  }
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in use_idx) {
    d = d csv_comma(count) $use_idx[i]
  }
  csv_data[++_set_data] = d
}

END {
  print_csv_header()
  print_csv_data()
}

function print_csv_header(    i, count) {
  for (i in use_idx) {
      printf csv_comma(count) idx_to_col[use_idx[i]]
  }
  print ""
}

function print_csv_data(    i) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in csv_data) {
    print csv_data[i]
  }
}

function csv_comma(count) {
  if (count["one"]++) {
    return ","
  }
}
