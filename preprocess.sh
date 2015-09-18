# Extract the header so we can find our columns of interest
bzcat ss13hus.csv.bz2 | head -n 1 > ss13hus.header.txt

# We will use the file line coordinates as the proxy for index columns
sed -e $'s/,/\\\n/g' ss13hus.header.txt > ss13hus.header.nsv

# Our desired headers
for i in "ST" "NP" "BDSP" "BLD" "RMSP" "TEN" "FINCP" \
    "FPARC" "HHL" "NOC" "MV" "VEH" "YBL"
do
    x=`grep -n ^$i$ ss13hus.header.nsv | cut -d':' -f 1`
    v="$v $x"
done

bzcat ss13hus.csv.bz2 | \
    cut -d, -f`echo $v | \
    sed 's/ /,/g'` | \
    bzip2 > preprocessed.csv.bz2
