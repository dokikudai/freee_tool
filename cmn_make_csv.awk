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

END {
  # BOM
  printf "\xEF\xBB\xBF"

  print_header_csv(output_header_cols)
  print_data_csv()
  # 未実装 労働保険の確定・概算仕訳
  # print_labor_insurance_sum()
}

function print_header_csv(cols    , i, col, str_cols, count) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in cols) {
    str_cols = str_cols csv_comma(count) cols[i]
  }
  print str_cols
}

function print_data_csv(    j1, counter) {
  PROCINFO["sorted_in"]="@ind_str_asc"
  # journalsループ
  for (j1 in journals) {
    if (cmn_is_date(j1)) {
      continue
    }
    output_csv_owner(journals[j1], j1)
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
    return cmn_strftime_skip_holiday(yyyy "/07/10")
  } else {
    return cmn_strftime_skip_holiday(yyyy + 1 "/07/10")
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
