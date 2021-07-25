## 労働保険

### 労働保険シェルスクリプト

```
./bin/cut_col_from_payroll.sh labor_insurance \
| ./bin/uniq_header.sh \
| ./bin/make_csv.sh labor_insurance -f 202103 -t 202106 \
| ./bin/save_to_file.sh labor_insurance
```

1. ./bin/cut_col_from_payroll.sh labor_insurance

1. ./bin/uniq_header.sh

1. ./bin/make_csv.sh labor_insurance

1. ./bin/save_to_file.sh

### 給与・賞与シェルスクリプト

```
./bin/cut_col_from_payroll.sh salarys \
| ./bin/uniq_header.sh \
| ./bin/make_csv.sh salarys -f 202101 -t 202103 \
| ./bin/save_to_file.sh salarys
```

1. ./bin/cut_col_from_payroll.sh salarys

1. ./bin/uniq_header.sh

1. ./bin/make_csv.sh salarys

1. ./bin/save_to_file.sh

```
./bin/cut_col_from_payroll.sh insurance \
| ./bin/uniq_header.sh \
| ./bin/make_csv.sh insurance -f 202103 -t 202103 \
| ./bin/save_to_file.sh insurance
```

編集中

freee create-csv-from-pyroll salarys --from --to
freee create-csv-from-pyroll labor_insurance --from --to
freee create-csv-from-pyroll sosial_insurance salarys --from --to

## 概要

freee の賃金台帳 csv より、社会保険料の会社分仕訳インポート csv を作成する。

## 機能・仕様

aws cli のようなコマンド形式にて表示をコントロールする。

aws make-import-csv social-insurance --from 202101 --to 202104 --debug --stdout --

### 計算機能

- 健康保険料（会社）
- 厚生年金保険料（会社）
- 介護保険料（会社）
- 子ども・子育て拠出金（会社）

### その他

- 決済期日は月末最終日で休日の場合は翌平日日
- メモタグに何月締め給与か記載
