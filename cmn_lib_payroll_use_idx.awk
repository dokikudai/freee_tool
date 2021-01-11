function cmn_lib_use_idx(v_use_idx) {
    # 労働保険で利用する項目
    if (v_use_idx == "labor") {
        use_idx[++idx] = col_to_idx["従業員番号"]
        use_idx[++idx] = col_to_idx["種別"]
        use_idx[++idx] = col_to_idx["雇用保険料"]
        use_idx[++idx] = col_to_idx["支給月日"]
        use_idx[++idx] = col_to_idx["給与計算締日（固定給）"]
        use_idx[++idx] = col_to_idx["総支給額"]
    }
    # 給与
    if (v_use_idx == "salarys") {
          # 利用CSV項目
        use_idx[++idx] = col_to_idx["基本給"]
        use_idx[++idx] = col_to_idx["賞与"]
        use_idx[++idx] = col_to_idx["住民税"]
        use_idx[++idx] = col_to_idx["健康保険料"]
        use_idx[++idx] = col_to_idx["介護保険料"]
        use_idx[++idx] = col_to_idx["厚生年金保険料"]
        use_idx[++idx] = col_to_idx["雇用保険料"]
        use_idx[++idx] = col_to_idx["所得税"]
        use_idx[++idx] = col_to_idx["非課税通勤手当"]
        use_idx[++idx] = col_to_idx["調整(精算済み)"]
        use_idx[++idx] = col_to_idx["調整(精算待ち)"]
        use_idx[++idx] = col_to_idx["天引き"]
    }
    # 社会保険料
    # 所得税
}
