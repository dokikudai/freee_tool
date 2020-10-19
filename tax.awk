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

$col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与" {
  tmp_tax[entry_date()][set_depertment()] += $col_to_idx["所得税"]
}

function set_depertment(    d, employee_no, no) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (d in department_of) {
    split(department_of[d], employee_no, ",")
    for (no in employee_no) {
      if ($col_to_idx["従業員番号"] == employee_no[no]) {
        return d
      }
    }
  }
  return "無所属"
}

END {
  # BOM
  printf "\xEF\xBB\xBF"

  print_header_csv(output_header_cols)
  print_data_csv()
}

function print_data_csv(    date, dep) {
  PROCINFO["sorted_in"]="@ind_str_asc"
  for (date in tmp_tax) {
    for (dep in tmp_tax[date]) {
      print_csv_journals(date, dep, tmp_tax[date][dep])
    }
  }
}

function print_csv_journals(entry_date, depertment, tax_value    , journals) {
  journals["所得税"][1]  = "支出"                           # 収支区分
  journals["所得税"][3]  = entry_date                       # 発生日
  journals["所得税"][4]  = entry_date                       # 決済期日
  journals["所得税"][6]  = depertment                       # 取引先
  journals["所得税"][7]  = "預り金"                         # 勘定科目
  journals["所得税"][8]  = "対象外"                         # 税区分
  journals["所得税"][9]  = tax_value                        # 金額
  journals["所得税"][12] = remarks(entry_date, depertment)  # 備考
  journals["所得税"][13] = "所得税"                         # 品目
  journals["所得税"][14] = depertment                       # 部門
  journals["所得税"][15] = tags(entry_date)                 # メモタグ（複数指定可、カンマ区切り）
  print create_data_csv(journals)
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

function print_header_csv(cols    , i, col, str_cols, count) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in cols) {
    str_cols = str_cols csv_comma(count) cols[i]
  }
  print str_cols
}

function create_data_csv(journals    , j, i, col, str_cols, count) {
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (j in journals) {
    for (i in output_header_cols) {
      if (i in journals[j]) {
        col = csv_comma(count) journals[j][i]
      } else {
        col = csv_comma(count)
      }
      str_cols = str_cols col
    }
  }
  return str_cols
}

function csv_comma(count) {
  if (count["one"]++) {
    return ","
  }
}
