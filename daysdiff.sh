D1=`date +%s -d "2007-12-19"`
D2=`date +%s -d "2008-02-09"`
((diff_sec=D2-D1))
echo - | awk -v SECS=$diff_sec '{printf "Number of days : %d",SECS/(60*60*24)}'
