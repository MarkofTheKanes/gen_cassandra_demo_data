
i=$1
columns=$(head -n 1 $i | tr '|' ',')
cqlsh -e "copy tnf.hrcc_historical_d_1 ($(echo $columns))  from '$(echo $i)'   with header = true and delimiter = '|'"
