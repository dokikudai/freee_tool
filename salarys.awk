BEGIN {
  PROCINFO["sorted_in"]="@ind_str_asc"
  init_use_csv_cols()
  init_ul_sal_vals()
  init_ul_officer_sal_vals()
  init_ul_sal_mounts()
}
function init_use_csv_cols(    i) {
  # 利用CSV項目
  use_csv_cols[++i] = "基本給"
  use_csv_cols[++i] = "賞与"
  use_csv_cols[++i] = "住民税"
  use_csv_cols[++i] = "健康保険料"
  use_csv_cols[++i] = "介護保険料"
  use_csv_cols[++i] = "厚生年金保険料"
  use_csv_cols[++i] = "雇用保険料"
  use_csv_cols[++i] = "所得税"
  use_csv_cols[++i] = "非課税通勤手当"
  use_csv_cols[++i] = "調整(精算済み)"
  use_csv_cols[++i] = "調整(精算待ち)"
  use_csv_cols[++i] = "天引き"
}
function init_ul_sal_vals(    i) {
  #                  "品目(item),               勘定科目(account), 備考(remarks),            tag       "
  ul_sal_vals[++i] = "給料賃金,                 給料賃金,          給料賃金,                 null"
  ul_sal_vals[++i] = "賞与,                     賞与,              賞与,                     null"
  ul_sal_vals[++i] = "住民税,                   預り金,            住民税,                   null"
  ul_sal_vals[++i] = "健康保険料（従業員）,     預り金,            健康保険料（従業員）,     社会保険料"
  ul_sal_vals[++i] = "介護保険料（従業員）,     預り金,            介護保険料（従業員）,     社会保険料"
  ul_sal_vals[++i] = "厚生年金保険料（従業員）, 預り金,            厚生年金保険料（従業員）, 社会保険料"
  ul_sal_vals[++i] = "雇用保険料（従業員）,     預り金,            雇用保険料（従業員）,     労働保険料"
  ul_sal_vals[++i] = "所得税,                   預り金,            所得税,                   null"
  ul_sal_vals[++i] = "通勤手当,                 通勤定期,          通勤手当,                 null"
  ul_sal_vals[++i] = "調整(精算済み),           給料調整（預り金）,調整(精算済み),           null"
  ul_sal_vals[++i] = "調整(精算待ち),           給料調整（預り金）,調整(精算待ち),           null"
  ul_sal_vals[++i] = "天引き,                   預り金,            天引き,                   null"
}
function init_ul_officer_sal_vals(    i) {
  #                  "品目(item),               勘定科目(account), 備考(remarks),            tag       "
  ul_officer_sal_vals[++i] = "役員報酬,         給料賃金,          役員報酬,                 null"
  ul_officer_sal_vals[++i] = "役員賞与,         賞与,              役員賞与,                 null"
}
function init_ul_sal_mounts(    i) {
  ul_sal_mounts[++i] = 1
  ul_sal_mounts[++i] = 1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = 1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = -1
  ul_sal_mounts[++i] = -1
}
NR == 1 {
  cmn_debug_log("NR == " NR ", NF = " NF)
  for (i = 1; i <= NF; i++) {
    if ($i) {
      csv_cols[$i] = i
      cmn_debug_log("csv_cols[\"" $i "\"] = " i )
      _check_cols[$i]++
    }
  }
  for (_ca in _check_cols) {
    if (_check_cols[_ca] > 1  && _ca != "\"\"") {
      print v_csv_list " に同名の項目があり、計算ミスが発生する場合があります。同名項目：" _ca
    } 
  }
}
$7 && $5=="給与" {
  set_main($5)
}
$7 && $5=="賞与" {
  cmn_debug_log("賞与チェック")
  set_main($5)
}

END {
  # BOM
  printf "\xEF\xBB\xBF"

  # HEAD
  print "収支区分,管理番号,発生日,決済期日,取引先コード,取引先,勘定科目,税区分,金額,税計算区分,税額,備考,品目,部門,メモタグ（複数指定可、カンマ区切り）,セグメント1,セグメント2,セグメント3,決済日,決済口座,決済金額"
  p(salarys)
  p(ets)
}

function set_main(salary_kbn,    usr_lib_salarys, i, ul_val) {
  for (i in use_csv_cols) {
    cmn_debug_log("aaa:" i ", " use_csv_cols[i])
    ul_val = ul_sal_vals[i]
    # 役員の場合
    cmn_debug_log("ul_officer_sal_vals[i]" ul_officer_sal_vals[i])
    if (is_officer() && ul_officer_sal_vals[i]) {
      cmn_debug_log("function_is_officer")
      ul_val = ul_officer_sal_vals[i]
    }
    if (use_csv_cols[i] in csv_cols) {
      usr_lib_salarys[i][$csv_cols[use_csv_cols[i]] * ul_sal_mounts[i]] = ul_val
    }
  }
  
  set_salarys(salary_kbn, usr_lib_salarys)
  set_ets()
}
function is_officer(    emp_no_of_officer, no_of, i) {
  # プロパティ的な設定として要改修
  emp_no_of_officer = "1, 2"
  split(emp_no_of_officer, no_of, ", *")
  for (i in no_of) {
    cmn_debug_log("is_officer#no_of[" i "] : " no_of[i])
    if ($2 == no_of[i]) {
      return 1
    }
  }
  return 0
}

function set_salarys(salary_kbn, usr_lib_salarys,    entry_date, no, value, lib_acc) {

  if (salary_kbn == "給与") {
    cmn_debug_log("給与entry_date判定")
    entry_date = cmn_entry_strdate()
  }

  if (salary_kbn == "賞与") {
    cmn_debug_log("賞与entry_date判定")
    entry_date = cmn_bounus_entry_strdate()
  }

  for (no in usr_lib_salarys) {
    for (value in usr_lib_salarys[no]) {

      split(usr_lib_salarys[no][value], lib_acc, /, */)
      # lib_acc[1] = item
      # lib_acc[2] = account
      # lib_acc[3] = remarks
      # lib_acc[4] = tag

      # 文字列を数字化
      if (value * 1) {
        cmn_debug_log("gensub $1 : " gensub(/[ 　]/, "", "g", $1))
        #cmn_debug_log(",," $9 "," $7 ",," $1 "," account ",対象外," value ",,," remarks "," item "," $1 ",\""tags"\",,,,,,")
        salarys[entry_date][salary_kbn][$2][no] = ",," entry_date "," cmn_pay_strdate() ",," cmn_emp_name() "," lib_acc[2] ",対象外," value ",,," lib_acc[3] "," lib_acc[1] "," cmn_emp_name() ",\"" get_tags(lib_acc[4]) "\",,,,,,"
      }
    }
  }
}

function set_ets(    usr_lib_ets, i, no, value, lib_acc, tags) {
  #          [No.][value   ]   "品目(item),               勘定科目(account), 備考(remarks),            tag       "
  usr_lib_ets[++i][$csv_cols["年末調整精算"] * -1] = "年末調整精算,             預り金,            年末調整精算,             null"

  for (no in usr_lib_ets) {
    for (value in usr_lib_ets[no]) {
      split(usr_lib_ets[no][value], lib_acc, /, */)
      # lib_acc[1] = item
      # lib_acc[2] = account
      # lib_acc[3] = remarks
      # lib_acc[4] = tag
      if (value * 1) {
        #gsub(" ", "", $1)
        ets[cmn_entry_strdate()]["tmp"][$2][no] = ",," cmn_entry_strdate() "," cmn_pay_strdate() ",," cmn_emp_name() "," lib_acc[2] ",対象外," value ",,," lib_acc[3] "," lib_acc[1] "," cmn_emp_name() ",\"" get_tags(lib_acc[4]) "\",,,,,,"
      }
    }
  }
}

function get_tags(tag,    tags) {
  tags = "import_給与"
  if (tag != "null") {
    tags = tags "," tag
  }
  return tags
}

function p(salarys,    entry_d, e, salary_kbn, _i, item, employee) {
  for (entry_d in salarys) {
    if (cmn_is_date(entry_d)) {
      continue
    }
    for (salary_kbn  in salarys[entry_d]) {
      for (employee in salarys[entry_d][salary_kbn]) {
        cmn_debug_log(employee)
        _i=0
        if (!_i++) {
          printf "支出"
        }
        for (item in salarys[entry_d][salary_kbn][employee]) {
          cmn_debug_log(item)
          print salarys[entry_d][salary_kbn][employee][item]
        }
      }
    }
  }
}
