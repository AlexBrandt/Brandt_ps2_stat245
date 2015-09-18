# wget --quiet www.stat.berkeley.edu/share/paciorek/ss13hus.csv.bz2
# echo "Finished downloading."

x=`wc -l <(bzcat ss13hus.csv.bz2)`
