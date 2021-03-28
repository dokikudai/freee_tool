($col_to_idx["種別"] == "給与" && $col_to_idx["基本給"]) || ($col_to_idx["種別"] == "賞与" && $col_to_idx["賞与"]) {
  set_data()
}

function set_data(    i, d, count) {
  if (cmn_is_date($col_to_idx["給与計算締日（固定給）"])) {
    return
  }
  PROCINFO["sorted_in"]="@ind_num_asc"
  for (i in use_idx) {
    # 賃金台帳の年度によってはまだ発生していないカスタム項目がある場合の対応
    if (use_idx[i]) {
      d = d csv_comma(count) $use_idx[i]
    } else {
      d = d csv_comma(count) ""
    }
  }
  csv_data[++_set_data] = d
}

function cmn_lib_use_idx() {
  set_use_idx(col_to_idx["従業員番号"])
  set_use_idx(col_to_idx["種別"])
  set_use_idx(col_to_idx["支給月日"])
  set_use_idx(col_to_idx["給与計算締日（固定給）"])
  set_use_idx(col_to_idx["基本給"])
  set_use_idx(col_to_idx["賞与"])
  set_use_idx(col_to_idx["健康保険料"])
  set_use_idx(col_to_idx["介護保険料"])
  set_use_idx(col_to_idx["厚生年金保険料"])
  set_use_idx(col_to_idx["雇用保険料"])
  set_use_idx(col_to_idx["住民税"])
  set_use_idx(col_to_idx["所得税"])
  set_use_idx(col_to_idx["非課税通勤手当"])
  set_use_idx(col_to_idx["調整(精算済み)"])
  set_use_idx(col_to_idx["調整(精算待ち)"])
  set_use_idx(col_to_idx["天引き"])
  set_use_idx(col_to_idx["年末調整精算"])
}
