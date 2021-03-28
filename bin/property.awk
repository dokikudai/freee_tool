# 部門設定
BEGIN {

  # 部門No-部門名設定
  #
  #            "部門No"= "部門名"
  # department_of[1] = "総務部"
  # department_of[2] = "営業部"

  department_of[1] = "菊池大地"
  department_of[2] = "菊池幸子"
  department_of[3] = "野極武"

  # 従業員No-所属No設定
  #
  #  "従業員No" = "所属している部門No"
  # work_in[1]  = 2    # 例：従業員No.1は部門No.2に所属している
  # work_in[2]  = 2
  # work_in[3]  = 1
  # work_in[4]  = 2
  # work_in[5]  = 1
  # work_in[12] = 1    # 例：従業員No.12は部門No.1に所属している

    work_in[1] = 1
    work_in[2] = 2
    work_in[3] = 3
}

function get_depertment(employee_num    , department_num) {
  department_num = work_in[employee_num]
  if (employee_num in work_in && department_num in department_of) {
    return department_of[department_num]
  }
  return "無所属"
}
