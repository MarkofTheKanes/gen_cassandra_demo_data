curl --cookie-jar test.cookie 'http://localhost:8009/cci/api/v1/login?user=boss&password=boss'
echo ""
curl --cookie     test.cookie \
'http://localhost:8009/cci/api/v1/subscriber/profile?imsi=272211221122333