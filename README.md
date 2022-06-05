## コマンドサンプル

- ボーナスの社会保険料

```
export LANG=ja_JP.utf8
./insurance_bounus.sh --from 202006 --to 202105 --debug
```

- 給料の社会保険料

```
export LANG=ja_JP.utf8
./insurance.sh --from 202006 --to 202105 --debug
```

- 保険料率のマスタ作成
```
bash social_insurances.sh 
```

## その他

- freee 人事労務 の 賃金台帳 csv の文字コードは utf8 なので、 awk で処理するときは sjis にしてから実施しないと出力 csv が壊れてしまう
