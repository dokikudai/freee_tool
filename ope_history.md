## 2023/04/28
### feature/kikudai/20210725 ブランチ
./bin/cut_col_from_payroll.sh labor_insurance \
| ./bin/uniq_header.sh \
| ./bin/make_csv.sh labor_insurance -f 202303 -t 202305 \
| ./bin/save_to_file.sh labor_insurance

./bin/cut_col_from_payroll.sh salarys \
| ./bin/uniq_header.sh \
| ./bin/make_csv.sh salarys -f 202303 -t 202305 \
| ./bin/save_to_file.sh salarys

### 保険料率のマスタ作成・・・協会けんぽから平成5年度3月以降のCSVダウンロード
bash social_insurances.sh 

### feature/kikudai/rev ブランチ
./insurance.sh --from 202303 --to 202305 --debug
./insurance_bounus.sh --from 202305 --to 202305 --debug
