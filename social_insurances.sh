find social_insurances/ -type f -name "*.csv" | while read -r line
do
  awk -F',' '$1~/^[0-9]/' ${line} |
    sed --regexp-extended '
      s/"([0-9]+),([0-9]{3}),([0-9]{3})"/\1\2\3/g
      s/"([0-9]+),([0-9]{3})(.[0-9]+)"/\1\2\3/g
      s/"([0-9]+),([0-9]{3})"/\1\2/g
    ' |
    awk -F',' '
      4 {
        printf $3 "," $5 "," $6 "," $7 "," $8 "," $9
        print "," nu($10) "," nu($11)
      }

      function nu(str) {
        if (str~/^[0-9]/) {
          return str
        } else {
          return ""
        }
      }
    ' > ${line}.tmp
done
