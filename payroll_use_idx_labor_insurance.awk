($col_to_idx["種別"] == "給与" || $col_to_idx["種別"] == "賞与") && $col_to_idx["雇用保険料"] {
  set_data()
}

function cmn_lib_use_idx(v_use_idx) {
    use_idx[++idx] = col_to_idx["従業員番号"]
    use_idx[++idx] = col_to_idx["種別"]
    use_idx[++idx] = col_to_idx["雇用保険料"]
    use_idx[++idx] = col_to_idx["支給月日"]
    use_idx[++idx] = col_to_idx["給与計算締日（固定給）"]
    use_idx[++idx] = col_to_idx["総支給額"]
}
