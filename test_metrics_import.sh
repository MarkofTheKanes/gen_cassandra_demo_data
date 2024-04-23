
url --cookie-jar test.cookie 'http://localhost:8009/cci/api/v1/login?user=boss&password=boss'
echo ""
curl --cookie     test.cookie \
'http://localhost:8009/cci/api/v1/subscriber/histdata?aggr=d&imsi=272211221122333&timefrom=20171016000000&timeto=20171115000000'
echo ""
