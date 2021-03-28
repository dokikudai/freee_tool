## 労働保険

### 労働保険シェルスクリプト

```
./bin/labor/cut_labor_insurance_col_from_payroll.sh \
| ./bin/uniq_header.sh \
| ./bin/labor/make_csv_labor_insurance.sh -f 202101 -t 202103 \
| ./bin/save_to_file.sh labor_insurance
```

1. cut_labor_insurance_col_from_payroll.sh

1. uniq_header.sh

1. make_csv_labor_insurance.sh

1. save_to_file.sh

### 給与・賞与シェルスクリプト

```
./bin/salary/cut_salarys_col_from_payroll.sh \
| ./bin/uniq_header.sh \
| ./bin/salary/make_csv_salarys.sh -f 202012 -t 202102 \
| ./bin/save_to_file.sh salarys
```

1. ./bin/salary/cut_salarys_col_from_payroll.sh
