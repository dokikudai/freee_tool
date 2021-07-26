BEGIN {
  PROCINFO["sorted_in"]="@ind_str_asc"
}

# 賃金台帳の従業員名からスペースを除く
function cmn_emp_name() {
  return gensub(/[ 　]/, "", "g", $col_to_idx["従業員名"])
}

# デバッグ用出力ログ
# スクリプト実行時に awk に -v debug_lfg=1とすることで出力
function cmn_debug_log(str) {
  if (v_debug_lfg) {
    print "[DEBUG" "] " strftime("%Y/%m/%d %H:%M:%S", systime()) " " str
  }
}

# 賃金台帳用の支給月日、計算締日をmktimeする
function cmn_to_mktime(strtime,    t_) {
  t_ = mktime(gensub("/", " ", "g", strtime) " 00 00 00")
  cmn_debug_log("cmn#cmn_to_mktime t_: " t_)
  return t_
}

# 計算締日（計上日）をstrftimeする
function cmn_entry_strdate(remarks,    lib_employee) {

  # リファクタリングしたい
  lib_employee["健康保険料（従業員）"]
  lib_employee["厚生年金保険料（従業員）"]
  lib_employee["介護保険料（従業員）"]

  if (remarks in lib_employee) {
    return cmn_pay_insur_strdate($col_to_idx["支給月日"])
  }
  return strftime("%Y/%m/%d", cmn_to_mktime($col_to_idx["給与計算締日（固定給）"]))
}

# 給与支払日をstrftimeする
function cmn_pay_strdate() {
  return strftime("%Y/%m/%d", cmn_to_mktime($col_to_idx["支給月日"]))
}

# 社会保険料支払い日をstrftimeする
function cmn_pay_insur_strdate(yyyymmdd,    _day, _mk) {
  _day = 24 * 60 * 60
  _mk = cmn_to_mktime(yyyymmdd)
  for (_h in holiday) {
    if (_h == _mk) {
      _mk += (1 * _day)
    }
    # 無駄処理は抜ける
    if (_mk + 1 * _day < _h) {
      break
    }
  }
  return strftime("%Y/%m/%d", _mk)
}

# ボーナスの計算締日をmktimeする
function cmn_bounus_entry_date(    d1, d2) {
  d1 = strftime("%Y %m 01", cmn_to_mktime($col_to_idx["支給月日"]))
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

# リファクタリングしたい
# ボーナスの社会保険料精算日をstrftimeする
function cmn_bounus_insura_settle_date(    d1, d2, d3) {
  d1 = strftime("%Y %m %d", cmn_to_mktime($col_to_idx["支給月日"]))
  cmn_debug_log("cmn#strftime(\"%Y %m 01\", d2) : " d1)
  d2 = mktime(d1 " 23 59 59") + 1
  # 1ヶ月以上プラス
  d2 = d2 + (24*60*60)*32
  # 月初から1秒引いて月末にする
  d3 = mktime(strftime("%Y %m 01", d2) " 00 00 00") - 1
  cmn_debug_log("cmn#mktime(d3 \" 00 00 00\") : " d3)
  cmn_debug_log("cmn#strftime(\"%Y/%m/%d %H:%M:%S\", d3) : " strftime("%Y/%m/%d %H:%M:%S", d3))
  return cmn_pay_insur_strdate(strftime("%Y/%m/%d", d3))
}

# 介護保険料の計算に必要な年齢を計算
function cmn_age(    entry_date, from, to) {
  if ($col_to_idx["種別"] == "給与") {
    entry_date = cmn_to_mktime($col_to_idx["給与計算締日（固定給）"])
  }
  if ($col_to_idx["種別"] == "賞与") {
    entry_date = cmn_to_mktime($col_to_idx["支給月日"])
  }
  # 年齢
  # https://xtech.nikkei.com/it/article/Watcher/20070822/280097/
  from = strftime("%Y%m%d", entry_date)
  to = strftime("%Y%m%d", (mktime(gensub("/", " ", "g", $col_to_idx["生年月日"]) " 00 00 00") - (24 * 60 * 60)))
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
      # このifバグの温床かも。厚生年金、子ども・子育て拠出金のときに
      if ($col_to_idx["健康保険標準報酬月額"] >= _i+0 && $col_to_idx["健康保険標準報酬月額"] < _j+0) {
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

function cmn_holiday_api(year    , i) {

  # 1回しか実行しない保険のif
  # curl 無限ループ防止
  if (_exe["one"]++) {
    exit 1
  }

  print "(curl -s https://holidays-jp.github.io/api/v1/" year "/datetime.csv && curl -s https://holidays-jp.github.io/api/v1/" year + 1 "/datetime.csv) | awk -F, '\''{print $1}'\''" |& "bash"
  close("bash", "to")
  while(("bash" |& getline _v_line) > 0) {
    holiday[_v_line]
  }
  close("bash")

  # 協会けんぽ休日
  holiday[mktime(year " 01 02 00 00 00")]
  holiday[mktime(year " 01 03 00 00 00")]
  holiday[mktime(year " 12 31 00 00 00")]
  holiday[mktime(year + 1 " 01 02 00 00 00")]
  holiday[mktime(year + 1 " 01 03 00 00 00")]

  # 土日
  for (i=mktime(year " 01 01 00 00 00"); i < mktime(year+1 " 12 31 23 59 59"); i+=(24*60*60)) {
    if (sprintf(strftime("%w", i)) == 6 || sprintf(strftime("%w", i)) == "0") {
      holiday[i]
    }
  }
}
