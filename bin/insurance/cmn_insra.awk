function cmn_insra_chk_kaigo(mount,    entry_strdate) {
  if ($5 == "給与") {
    entry_strdate = cmn_entry_strdate()
  }
  if ($5 == "賞与") {
    entry_strdate = cmn_bounus_entry_strdate()
  }
  if (mount > 0 && mount != $61) {
    print "介護保険料（従業員）の金額が合っていません。 "entry_strdate " " cmn_emp_name() " " cmn_age() "歳 賃金台帳*.csv " FNR "行目 " mount " != " $61
  }
}

function cmn_insra_chk_welfare(stat, mount) {
  if (stat == "employee" && mount != $62) {
    print "厚生年金保険料（従業員）の金額が合っていません。"entry_strdate " " cmn_emp_name() " " cmn_age() "歳 賃金台帳*.csv " FNR "行目 " mount " != " $62
  }
}

function cmn_insra_chk_health(stat, mount) {
  if (stat == "employee" && mount != $60) {
    print "健康保険料（従業員）の金額が合っていません。 "entry_strdate " " cmn_emp_name() " " cmn_age() "歳 賃金台帳*.csv " FNR "行目 " mount " != " $60
  }
}
