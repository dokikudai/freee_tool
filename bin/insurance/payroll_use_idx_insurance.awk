($col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与") && $col_to_idx["社会保険料等控除合計"] {
  set_data()
}

function cmn_lib_use_idx() {
  set_use_idx(col_to_idx["従業員番号"])
  set_use_idx(col_to_idx["種別"])
  set_use_idx(col_to_idx["支給月日"])
  set_use_idx(col_to_idx["給与計算締日（固定給）"])
  set_use_idx(col_to_idx["生年月日"])
  set_use_idx(col_to_idx["健康保険料"])
  set_use_idx(col_to_idx["介護保険料"])
  set_use_idx(col_to_idx["厚生年金保険料"])
  set_use_idx(col_to_idx["社会保険料等控除合計"])
  set_use_idx(col_to_idx["健康保険標準報酬月額"])
  set_use_idx(col_to_idx["厚生年金保険標準報酬月額"])
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
