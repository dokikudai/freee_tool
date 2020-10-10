# 賃金台帳の従業員名からスペースを除く
function cmn_emp_name() {
  return gensub(/[ 　]/, "", "g", $1)
}

# デバッグ用出力ログ
# スクリプト実行時に awk に -v debug_lfg=1とすることで出力
function cmn_debug_log(str) {
  if (v_debug_lfg) {
    print "[DEBUG" "] " strftime("%Y/%m/%d %H:%M:%S", systime()) " " str
  }
}

# 賃金台帳用の支給月日、計算締日をmktimeする
function cmn_to_mktime(strtime,    d1, d2) {
  d1 = gensub("/", " ", "g", strtime)
  cmn_debug_log("cmn#gensub(\"/\", \" \", \"g\", " strtime ") : " d1)
  d2 = mktime(d1 " 00 00 00")
  cmn_debug_log("cmn#mktime(d1 \" 00 00 00\") : " d2)
  return d2
}

# 計算締日（計上日）をstrftimeする
function cmn_entry_strdate(remarks,    lib_employee) {

  # リファクタリングしたい
  lib_employee["健康保険料（従業員）"]
  lib_employee["厚生年金保険料（従業員）"]
  lib_employee["介護保険料（従業員）"]

  if (remarks in lib_employee) {
    return cmn_pay_strdate()
  }
  return strftime("%Y/%m/%d", cmn_to_mktime($9) " 00 00 00")
}

# 給与支払日をstrftimeする
function cmn_pay_strdate() {
  return strftime("%Y/%m/%d", cmn_to_mktime($7) " 00 00 00")
}

# ボーナスの計算締日をmktimeする
function cmn_bounus_entry_date(    d1, d2) {
  d1 = strftime("%Y %m 01", cmn_to_mktime($7))
  cmn_debug_log("cmn#strftime(\"%Y %m 01\", d2) : " d1)
  d2 = mktime(d1 " 00 00 00") - 1
  cmn_debug_log("cmn#mktime(d1 \" 00 00 00\") : " d2)
  cmn_debug_log("cmn#strftime(\"%Y/%m/%d %H:%M:%S\", d2) : " strftime("%Y/%m/%d %H:%M:%S", d2))
  return  d2
}

# ボーナスの計算締日をstrftimeする
function cmn_bounus_entry_strdate(remarks,    d) {
  # リファクタリングしたい
  lib_employee["健康保険料（従業員）"]
  lib_employee["厚生年金保険料（従業員）"]
  lib_employee["介護保険料（従業員）"]

  if (remarks in lib_employee) {
    return cmn_pay_strdate()
  }

  d = strftime("%Y/%m/%d", cmn_bounus_entry_date())
  cmn_debug_log("cmn#strftime(\"%Y/%m/%d\", cmn_bounus_entry_date()) : " d)
  return d
}

# 介護保険料の計算に必要な年齢を計算
function cmn_age(    entry_date, from, to) {
  if ($5 == "給与") {
    entry_date = cmn_to_mktime($9)
  }
  if ($5 == "賞与") {
    entry_date = cmn_to_mktime($7)
  }
  # 年齢
  # https://xtech.nikkei.com/it/article/Watcher/20070822/280097/
  from = strftime("%Y%m%d", entry_date)
  to = strftime("%Y%m%d", (mktime(gensub("/", " ", "g", $4) " 00 00 00") - (24 * 60 * 60)))
  age = int((from - to) / 10000)
  cmn_debug_log("age = " age)
  return age
}

function cmn_roundoff(value, stat) {
  if (stat=="owner") {
    return int(value + 0.5)
  }
  if (stat=="employee") {
    return int(value + 0.49)
  }
}

function cmn_get_val(lib_si, insurance_name,    _i,_j){
  for (_i in lib_si) {
    for (_j in lib_si[_i]) {
      if ($77 >= _i+0 && $77 < _j+0) {
        return lib_si[_i][_j][insurance_name]
      }
    }
  }
}

function cmn_bigdecimal(decimal) {
  cmn_chk_decimal(decimal, "cmn_bigdecimal")
  return sprintf("%.2f", decimal)
}

function cmn_rounddown(decimal) {
  cmn_chk_decimal(decimal, "cmn_rounddown")
  return int(decimal)
}

function cmn_chk_decimal(decimal, fuc_name) {
  if (decimal !~ /^[0-9]+(\.[0-9]+)?$/) {
    return "ERROR: " fuc_name " function."
  }
}

function cmn_is_date(entry_d,    from, to, ed) {
  if (v_from == "" && v_to == "") {
    return 0
  }
  from = mktime(substr(v_from, 1, 4) " " substr(v_from, 5, 2) " 01 00 00 00")
  cmn_debug_log(substr(v_from, 1, 4) " " substr(v_from, 5, 2) " 01 00 00 00")
  cmn_debug_log("from : " strftime("%Y/%m/%d", from))
  to = mktime(substr(v_to, 1, 4) " " substr(v_to, 5, 2) + 1 " 01 00 00 00") - 1
  cmn_debug_log("to : " strftime("%Y/%m/%d", to))
  cmn_debug_log("entry_d : " entry_d)
  ed = cmn_to_mktime(entry_d)
  cmn_debug_log("ed : " ed)
  return !(from <= ed && to >= ed)
}
