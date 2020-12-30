## 労働保険

### 労働保険シェルスクリプト
```
cut_labor_insurance_col_from_payroll.sh \
| uniq_header.sh \
| make_csv_labor_insurance.sh \
| save_to_file.sh
```

1. cut_labor_insurance_col_from_payroll.sh  

1. uniq_header.sh

1. make_csv_labor_insurance.sh

1. save_to_file.sh
