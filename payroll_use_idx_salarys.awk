($col_to_idx["種別"] == "給与" && $col_to_idx["基本給"]) || ($col_to_idx["種別"] == "賞与" && $col_to_idx["賞与"]) {
  set_data()
}

function cmn_lib_use_idx(v_use_idx) {
    use_idx[++idx] = col_to_idx["従業員番号"]
    use_idx[++idx] = col_to_idx["種別"]
    use_idx[++idx] = col_to_idx["支給月日"]
    use_idx[++idx] = col_to_idx["給与計算締日（固定給）"]
    use_idx[++idx] = col_to_idx["基本給"]
    use_idx[++idx] = col_to_idx["賞与"]
    use_idx[++idx] = col_to_idx["健康保険料"]
    use_idx[++idx] = col_to_idx["介護保険料"]
    use_idx[++idx] = col_to_idx["厚生年金保険料"]
    use_idx[++idx] = col_to_idx["雇用保険料"]
    use_idx[++idx] = col_to_idx["住民税"]
    use_idx[++idx] = col_to_idx["所得税"]
    use_idx[++idx] = col_to_idx["非課税通勤手当"]
    use_idx[++idx] = col_to_idx["調整(精算済み)"]
    use_idx[++idx] = col_to_idx["調整(精算待ち)"]
    use_idx[++idx] = col_to_idx["天引き"]
    use_idx[++idx] = col_to_idx["年末調整精算"]
}
