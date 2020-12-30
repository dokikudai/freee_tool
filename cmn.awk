BEGIN {
  PROCINFO["sorted_in"]="@ind_str_asc"
  SQ="\047"
}

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
function cmn_to_mktime(strtime) {
  return mktime(gensub("/", " ", "g", strtime) " 00 00 00")
}

# 計算締日（計上日）をstrftimeする
function cmn_entry_strdate(remarks,    lib_employee) {

  # リファクタリングしたい
  lib_employee["健康保険料（従業員）"]
  lib_employee["厚生年金保険料（従業員）"]
  lib_employee["介護保険料（従業員）"]

  # 未払金のタイミングをずらすため
  if (remarks in lib_employee) {
    return cmn_strftime_skip_holiday($7)
  }
  return strftime("%Y/%m/%d", cmn_to_mktime($9))
}

# 給与支払日をstrftimeする
function cmn_pay_strdate() {
  return strftime("%Y/%m/%d", cmn_to_mktime($7))
}

# 社会保険料支払い日をstrftimeする
# cmn_pay_insur_strdate
# 休日・休暇をスキップした平日日付を返す
function cmn_strftime_skip_holiday(yyyymmdd    , yyyy, day, mk) {

  yyyy = substr(yyyymmdd, 1, 4)
  _open_master_holiday(yyyy)

  # holiday初期化
  _init_holiday(yyyy)

  day = 24 * 60 * 60
  mk = cmn_to_mktime(yyyymmdd)

  PROCINFO["sorted_in"]="@ind_num_asc"
  for (_h in holiday[yyyy]) {
    if (_h == mk) {
      mk += (1 * day)
    }
    # 無駄処理は抜ける
    if (mk + 1 * day < _h) {
      break
    }
  }
  return strftime("%Y/%m/%d", mk)
}

# 支給月日からボーナス計算締日を計算 YYYY/MM/DD
function _cmn_bounus_entry_date(pay_date    ,d1, d2) {
  d1 = strftime("%Y %m 01", cmn_to_mktime(pay_date))
  d2 = mktime(d1 " 00 00 00") - 1
  return strftime("%Y/%m/%d", d2)
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

# リファクタリングしたい
# ボーナスの社会保険料精算日をstrftimeする
function cmn_bounus_insura_settle_date(    d1, d2, d3) {
  d1 = strftime("%Y %m %d", cmn_to_mktime($7))
  cmn_debug_log("cmn#strftime(\"%Y %m 01\", d2) : " d1)
  d2 = mktime(d1 " 23 59 59") + 1
  # 1ヶ月以上プラス
  d2 = d2 + (24*60*60)*32
  # 月初から1秒引いて月末にする
  d3 = mktime(strftime("%Y %m 01", d2) " 00 00 00") - 1
  cmn_debug_log("cmn#mktime(d3 \" 00 00 00\") : " d3)
  cmn_debug_log("cmn#strftime(\"%Y/%m/%d %H:%M:%S\", d3) : " strftime("%Y/%m/%d %H:%M:%S", d3))
  return cmn_strftime_skip_holiday(strftime("%Y/%m/%d", d3))
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

function _init_api_other_holiday(year    , _holiday, i, _h) {

  if (year !~ /^2[0-9]{3}$/) {
    print "WARN: 引数yearは不正な文字列です。 " year > "/dev/stderr"
    exit 1
  }

  # 1回しか実行しない保険のif
  # curl 無限ループ防止
  if (__init_api_other_holiday[year]++) {
    print "WARN: " year "は _init_api_other_holiday を複数回呼び出しています。" > "/dev/stderr"
    exit 1
  }

  cmn_debug_log("---------------- cmn#_init_api_other_holiday curl api ----------------" ++__init_api_other_holiday)

  print "curl -s https://holidays-jp.github.io/api/v1/" year "/datetime.csv | awk -F, " SQ "{print $1}" SQ |& "bash"
  close("bash", "to")
  while(("bash" |& getline _v_line) > 0) {
    holiday[year][_v_line]
    #ファイル書き込み用連想配列
    _holiday[year][_v_line]
  }
  close("bash")

  # 協会けんぽ休日
  holiday[year][mktime(year " 01 02 00 00 00")]; _holiday[year][mktime(year " 01 02 00 00 00")]
  holiday[year][mktime(year " 01 03 00 00 00")]; _holiday[year][mktime(year " 01 03 00 00 00")]
  holiday[year][mktime(year " 12 31 00 00 00")]; _holiday[year][mktime(year " 12 31 00 00 00")]

  # 土日
  for (i=mktime(year " 01 01 00 00 00"); i < mktime(year " 12 31 23 59 59"); i+=(24*60*60)) {
    if (sprintf(strftime("%w", i)) == "6" || sprintf(strftime("%w", i)) == "0") {
      holiday[year][i]
      _holiday[year][i]
    }
  }

  PROCINFO["sorted_in"]="@ind_str_asc"
  for (_h in _holiday[year]) {
    print year "," _h > "./master/holiday/" year ".txt"
  }
}

function _open_master_holiday(yyyy    , d) {
  if (__open_master_holiday[yyyy]++) {
    return
  }

  print "./holiday.sh" |& "bash"
  close("bash", "to")
  while(("bash" |& getline _v_line) > 0) {
    split(_v_line, d , ",")
    holiday[d[1]][d[2]]
  }
  close("bash")
}

function _init_holiday(year) {

  if (year !~ /^2[0-9]{3}$/) {
    print "WARN: 引数yearは不正な文字列です。 _init_holiday " year > "/dev/stderr"
    exit 1
  }

  if (year in holiday) {
    return
  }

  # 1回しか実行しない保険のif
  # curl 無限ループ防止
  if (__init_holiday[year]++) {
    print "WARN: " year "は _init_holiday を複数回呼び出しています。" > "/dev/stderr"
    return
  }
  _init_api_other_holiday(year)
}

# 5捨5超入
function in_over5(n    , int_n, decimal_n) {
  int_n = int(n)
  decimal_n = n - int_n
  if (decimal_n > 0.5) {
    return int_n + 1
  }
  return int_n
}

# 4捨5入
function round_half_up(n    , int_n, decimal_n) {
  int_n = int(n)
  decimal_n = n - int_n
  if (decimal_n >= 0.5) {
    return int_n + 1
  }
  return int_n
}
