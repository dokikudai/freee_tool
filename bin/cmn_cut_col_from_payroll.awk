BEGIN {
  # 賃金台帳の改行コードがCRLFのため、末尾のヘッダーが読み込めない問題を解消
  # https://ja.stackoverflow.com/questions/55229/awk-%e3%82%b3%e3%83%9e%e3%83%b3%e3%83%89%e3%81%ab%e3%82%88%e3%82%8b%e5%88%97%e3%81%ae%e4%b8%a6%e3%81%b3%e6%9b%bf%e3%81%88%e3%81%a7crlf%e6%94%b9%e8%a1%8c%e3%82%b3%e3%83%bc%e3%83%89%e3%81%ae%e6%89%b1%e3%81%84%e3%81%ab%e3%81%a4%e3%81%84%e3%81%a6
  RS="\r\n"
}

# 賃金台帳の項目名から index に変換の連想配列を作成
# 例えば、 $col_to_idx["従業員名"] で $1 と同様の結果が得られる
NR == 1 {
  create_conv_lib($0)
}

function create_conv_lib(payroll_book_csv_header    , p, i, count, column_name, debug_idx) {
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
  cmn_lib_use_idx()

  if (v_debug_lfg) {
    for (debug_idx in use_idx) {
      cmn_debug_log("cmn_cut_col_from_payroll.awk#create_conv_lib: use_idx, col = " use_idx[debug_idx] ", " debug_idx)
    }
  }
}

function set_use_idx(col) {
  cmn_debug_log("cmn_cut_col_from_payroll.awk#set_use_idx: col = " col)
  if (col) {
    use_idx[++idx] = col
  }
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
