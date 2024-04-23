#!/usr/bin/bash
#******************************************************************************
# Title: genJSON.sh
# Description: Generates daily dummy volume data values per Site and CES aggregation values
# for loading to CCI Cassandra DB for the following metrics:
#
#		ibmaaf_bytestotal_by_cell_sitename
#		ibmaaf_bytestotal
#		ibmaaf_set_cesaggregation_video_by_cell
#		
#		Sample output:
#		
# imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal|ibmaaf_set_cesaggregation_video_by_cell|dt|sgm
#
# 272211221122333|20171016000000|{"metricId":"ibmaaf_bytestotal_by_cell_sitename","counters":[{"breakdown":"Belt Line Road","value":[2856143]},{"breakdown":"Las Colinas","value":[10390032]},{"breakdown":"Irving","value":[12252781]},{"breakdown":"valley Ranch","value":[3698037]},{"breakdown":"Market Center","value":[24420174]},{"breakdown":"West Dallas","value":[6384488]},{"breakdown":"Cockrell Hill","value":[17608166]}]}|{"metricId":"ibmaaf_bytestotal","counters":[{"value":[87699098]}]}|{"metricId":"ibmaaf_set_cesaggregation_video_by_cell","counters":[{"breakdown":"Belt Line Road","value":[1,27,14,5,5]},{"breakdown":"Las Colinas","value":[2,3,23,8,29]},{"breakdown":"Irving","value":[16,79,166,1279,460]},{"breakdown":"Valley Ranch","value":[7,75,140,1352,408]},{"breakdown":"Market Centre","value":[7,75,140,1352,408]},{"breakdown":"West Dallas","value":[2,27,68,133,452]},{"breakdown":"Cockrell Hill","value":[19,95,174,1290,360]}]}|201710160000|0
# 
# Improvements:
#
# Author: Mark O'Kane
# History:
# 	ver 1 - 17/10/17
# Comments:
# Dependencies: None
#******************************************************************************

clear
## Check command line arguments
if [ $# -ne 2 ]
then
	echo " "
	echo "Usage $0 [IMSI]"
	echo " "
	echo -e "- IMSI: the IMSI the data is to be generated for e.g. 272211221122333"
	echo -e "- Debug value: 0 = off, 1 = on"
	echo -e "\ne.g. ./test.sh 272211221122333 1"
	echo " "
exit 2
fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************
## input params
imsival=$1
debugVal=$2

#*******************************************************************************************
# declare and create shared arrays
#*******************************************************************************************

# num_days_count=0

### #1 SITE ARRAYS ###
# Declare and create the array to hold the list of SITES to be used
declare -a SITES_ARRAY
SITES_ARRAY=("Belt Line Road" "Las Colinas" "Irving" "valley Ranch" "Market Center" "West Dallas" "Cockrell Hill")

# determine last index value of SITES_ARRAY. -1 used as index starts at 0
let SITES_ARRAY_last_index_val="${#SITES_ARRAY[@]}"
echo -e "\nNumber of sites: $SITES_ARRAY_last_index_val"

let count1=0
while [ $count1 -lt $SITES_ARRAY_last_index_val ] 
do
	if [ "$debugVal" -eq 1 ]; then echo -e "\nSITES_ARRAY element $count1 = ${SITES_ARRAY[$count1]}" >> debug.log; fi
	let "count1 += 1"
done

## #2 BYTES PER SITE ARRAY ###
# Declare and create the array to hold the daily bytes per site
declare -a BYTE_PER_SITE_ARRAY
BYTE_PER_SITE_ARRAY=(2856143 805999 22348 3059602 2490721 3991158 2510498 2106218 518267 14175007 3308955 1416175 5000857 1482960 1989530 0 0 247632 3462197 7487151 6304195 3227284 1525376 1387562 3448939 3844013 1422016 6606696 0 3284214 388681 10390032 2206114 0 10685901 1439512 4601464 7834709 7437851 5746733 354 5850030 3833 1123207 6800678 821050 95385 5291 7280504 2389562 1253871 2219856 1343446 522285 8894124 8414122 9643889 4731974 2317082 31357 114537 3804969 12252781 1739719 706667 2629722 18033038 22556593 7184684 16699183 19373821 9506900 10328233 13077926 1666256 461324 4686919 5546083 14399121 11154817 9170138 2852839 3415724 669151 3902025 5701124 10129338 2498547 7646862 4728603 437817 14701331 2178599 3698037 4899452 196981 26104200 256877 31732031 15591595 4053546 451357 2426104 3845356 2798958 78669642 186171892 976157 423249 2780149 2717060 2920650 84612821 45355692 1535296 4166054 4756121 4122781 2042197 94993769 31171191 2678614 1501237 2401893 24420174 81319238 36513933 81732031 105591595 0 0 31436598 59640094 77490330 31802313 33033511 0 0 17528658 59600577 37479085 40539416 67060027 0 0 30555339 74769849 41549960 44228285 71673202 0 0 51447612 66093615 44301378 6384488 3917663 5524115 7181422 6889838 0 0 2029343 5924687 6485225 1829957 1718513 0 0 4603463 921783 7897967 1020630 2597484 0 0 506290 963631 2302769 3073751 6211861 0 0 6304550 5661640 5395565 17608166 12289790 19129635 21384395 14419565 0 0 6439897 21634294 25851330 22116020 19397884 0 0 16983343 4422340 16191021 22823122 13175894 0 0 25958726 6519087 15310304 20635270 17481213 0 0 2770635 16481822 19456950)

# determine last index value of BYTE_PER_SITE_ARRAY. -1 used as index starts at 0
let BYTE_PER_SITE_ARRAY_last_index_val="${#BYTE_PER_SITE_ARRAY[@]}"
echo -e "o Number of data entries for BYTE_PER_SITE_ARRAY: $BYTE_PER_SITE_ARRAY_last_index_val"

let count2=0
while [ $count2 -lt $BYTE_PER_SITE_ARRAY_last_index_val ] 
do
	if [ "$debugVal" -eq 1 ]; then echo -e "\nBYTE_PER_SITE_ARRAY element $count2 = ${BYTE_PER_SITE_ARRAY[$count2]}" >> debug.log; fi
	let "count2 += 1"
done

### #3 DATE RANGE ARRAY ###
# Declare and create the array to hold the range of dates data is to be generated for
declare -a DATE_RANGE_ARRAY
DATE_RANGE_ARRAY=(20171016000000 20171017000000 20171018000000 20171019000000 20171020000000 20171021000000 20171022000000 20171023000000 20171024000000 20171025000000 20171026000000 20171027000000 20171028000000 20171029000000 20171030000000 20171031000000 20171101000000 20171102000000 20171103000000 20171104000000 20171105000000 20171106000000 20171107000000 20171108000000 20171109000000 20171110000000 20171111000000 20171112000000 20171113000000 20171114000000 20171115000000)

# determine last index value of DATE_RANGE_ARRAY. -1 used as index starts at 0
let DATE_RANGE_ARRAY_last_index_val="${#DATE_RANGE_ARRAY[@]}"
echo -e "o Number of days to generate data for is $DATE_RANGE_ARRAY_last_index_val"

let count3=0
while [ $count3 -lt $DATE_RANGE_ARRAY_last_index_val ] 
do
	if [ "$debugVal" -eq 1 ]; then echo -e "\nDATE_RANGE_ARRAY element $count3 = ${nDATE_RANGE_ARRAY[$count3]}" >> debug.log; fi
	let "count3 += 1"
done

### #4 TOTAL DAILY BYTES PER SITE ARRAY ###
# Declare and create the array to hold the range of daily bytes per site
declare -a DAILY_BYTES_SITE
DAILY_BYTES_SITE=(87699098 121111112 70165857 172638318 168506895 71055808 37427279 79328979 128016856 153606833 89361376 80734884 97699757 220256045 53775706 80240641 88990476 96934995 113876826 108713551 64743878 72088951 104376187 90289219 106279309 128136262 122937922 50650636 71947761 121857387 88058680)

# determine last index value of DAILY_BYTES_SITE. -1 used as index starts at 0
let DAILY_BYTES_SITE_last_index_val="${#DAILY_BYTES_SITE[@]}"
echo -e "o Number of data entries for DAILY_BYTES_SITE: $DAILY_BYTES_SITE_last_index_val"

let count4=0
while [ $count4 -lt $DAILY_BYTES_SITE_last_index_val ] 
do
		if [ "$debugVal" -eq 1 ]; then echo -e "\nDAILY_BYTES_SITE element $count4 = ${DAILY_BYTES_SITE[$count4]}" >> debug.log; fi
	let "count4 += 1"
done

### #5 Daily Video CES Score per site ARRAY ###
# Declare and create the array to hold the range of daily bytes per site
declare -a VIDEO_CES_ARRAY
VIDEO_CES_ARRAY=(1 2 0 0 0 13 24 0 0 0 1 3 11 14 0 0 0 29 23 19 8 0 0 30 0 0 20 19 2 0 23 27 19 0 12 0 22 28 0 4 0 11 17 25 29 12 0 19 28 68 28 1 0 0 73 0 0 28 12 15 0 81 14 66 0 28 0 25 3 0 19 4323 18 75 30 11 73 0 60 4 133 23 22 0 0 104 0 2345 19 11 10 0 105 5 255 0 16 0 15 24 0 7 212 26 140 20 30 270 0 186 14 1362 11 18 0 0 1338 0 53421 8 23 11 0 1361 5 302 0 23 0 30 27 0 10 0 3 362 20 20 432 0 338 5 467 5 9 0 0 378 0 0 27 27 0 0 308 2 21 8 21 28 128 303 14 29 24 20 18 94 209 4 28 16 24 18 148 368 0 18 9 29 23 430 81 28 15 17 3 2 13 0 6 175 116 15 21 22 8 3 284 275 12 3 29 16 4 455 114 2 29 5 1 25 83 171 15 8 23 23 12 14 18 3 372 438 21 18 9 2 25 277 282 4 6 10 10 15 387 123 12 11 15 25 16 216 193 1 13 20 8 29 16 2 11 112 121 13 23 6 6 18 402 211 18 1234 11 8 19 279 318 24 20 3 6 0 95 491 5 20 6 29 1 0 17 18 421 444 1 14 15 26 15 209 358 30 45086 13 27 24 332 104 1 16 11 9 9 92 149 11 11 14 16 9 18 26 4 14 67 17 27 10 1 20 45 93 20 20 10 6 13 94 63 7 3 8 29 18 62 13 26 15 30 79 116 135 120 117 105 192 89 125 141 57 100 274 177 121 64 102 90 78 201 161 71 129 130 129 131 251 185 107 138 131 166 138 111 123 158 472 434 152 168 168 111 121 541 546 142 196 185 119 156 592 376 119 176 179 113 192 507 532 109 173 112 1279 1388 1374 1232 1318 2087 2348 1313 1314 1366 1377 1303 1890 1991 1208 1276 1236 1314 1223 1700 1931 1344 1223 1323 1330 1245 1816 2093 1352 1263 1300 460 421 385 314 367 2707 2123 309 381 495 396 407 2570 2072 357 361 336 407 500 2281 2739 365 455 495 470 411 2574 2317 418 323 483 7 3 11 16 30 83 64 0 20 6 1 20 16 99 14 2 7 0 2 16 44 27 9 17 29 9 8 8 10 15 8 75 111 105 139 92 189 231 124 78 112 66 66 236 168 128 54 73 113 118 106 182 108 68 105 122 894 130 130 102 138 130 140 184 163 105 121 430 382 129 159 181 132 119 501 463 107 141 176 177 180 543 418 121 160 180 169 1754 179 179 185 173 179 1352 1325 1326 1214 1321 2183 2104 1321 1338 1204 1322 1271 2009 1834 1375 1304 1279 1380 1373 1745 2280 1363 1360 1355 1222 45 1323 1323 1236 1263 1323 408 441 484 302 416 2531 2681 355 409 438 421 365 2601 2197 469 497 324 320 433 2165 2253 368 491 320 441 320 495 495 336 323 495 7 3 11 16 30 0 0 0 20 6 1 20 0 0 14 2 7 0 2 0 0 27 9 17 2362 3500 0 0 1357 1839 3200 75 111 105 139 92 0 0 124 78 112 66 66 0 0 128 54 73 113 118 0 0 108 68 105 1800 1800 0 0 234 0 0 140 184 163 105 121 0 0 129 159 181 132 119 0 0 107 141 176 177 180 0 0 121 160 180 442 203 0 0 0 0 0 1352 1325 1326 1214 1321 0 0 1321 1338 1204 1322 1271 0 0 1375 1304 1279 1380 1373 0 0 1363 1360 1355 154 123 0 0 0 0 0 408 441 484 302 416 0 0 355 409 438 421 365 0 0 469 497 324 320 433 0 0 368 491 320 2 0 0 0 0 0 0 2 2 0 2 2 0 0 5 0 2 0 4 0 0 2 4 4 5 3 0 0 4 0 4 0 4 0 0 2 0 1 27 19 17 12 26 0 0 21 12 16 26 27 0 0 12 23 24 18 28 0 0 20 22 10 10 15 0 0 16 15 14 68 72 72 64 69 0 0 67 73 76 63 76 0 0 72 76 75 90 89 0 0 73 82 62 76 74 0 0 84 84 86 133 211 108 162 206 0 0 184 272 131 274 271 0 0 229 298 214 144 120 0 0 276 212 227 188 115 0 0 118 216 278 452 471 348 434 479 0 0 498 480 441 441 326 0 0 428 300 430 417 307 0 0 330 460 366 314 301 0 0 489 315 493 19 11 30 16 18 0 0 3 18 6 17 9 0 0 22 3 17 30 9 0 0 25 15 18 27 21 0 0 18 29 12 95 144 115 125 104 0 0 116 142 127 125 106 0 0 142 68 92 69 59 0 0 140 146 84 53 141 0 0 149 105 116 174 157 151 113 144 0 0 163 115 174 185 173 0 0 167 157 119 200 164 0 0 139 178 190 126 163 0 0 106 118 157 1290 1243 1300 1311 1322 0 0 1387 1373 1282 1262 1270 0 0 1376 1295 1241 1267 1352 0 0 1248 1281 1399 1268 1222 0 0 1345 1250 1224 360 471 405 335 350 0 0 357 479 430 370 317 0 0 333 379 439 390 320 0 0 395 353 488 305 349 0 0 353 320 405)

# determine last index value of DAILY_BYTES_SITE. -1 used as index starts at 0
let VIDEO_CES_ARRAY_last_index_val="${#VIDEO_CES_ARRAY[@]}"
echo -e "o Number of data entries for VIDEO_CES_ARRAY: $VIDEO_CES_ARRAY_last_index_val"

let count5=0
while [ $count5 -lt $VIDEO_CES_ARRAY_last_index_val ] 
do
	if [ "$debugVal" -eq 1 ]; then echo -e "\nVIDEO_CES_ARRAY element $count5 = ${VIDEO_CES_ARRAY[$count5]}" >> debug.log; fi
	let "count5 += 1"
done
########### END OF ARRAYS #############################
echo -e "\n"

#*******************************************************************************************
# define functions
#*******************************************************************************************
## Backup old output file. Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it
timestamp=`exec date +%y%m%d%H%M%S`

backup_old_files ()

## Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.
{
if [ -e GeneratedJSON.csv ]
then
	echo -e "\n# Renaming old output file and adding header"
	mv GeneratedJSON.csv GeneratedJSON-${timestamp}.csv
	echo "imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal|ibmaaf_set_cesaggregation_video_by_cell|dt|sgm"  > GeneratedJSON.csv
else
	echo "imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal|ibmaaf_set_cesaggregation_video_by_cell|dt|sgm"  > GeneratedJSON.csv
fi

## remove old debug file
if [ "$debugVal" -eq 1 ]
then
	if [ -e debug.log ] 
	then 
		echo -e "\n# Debug turned on.\n# Removing old debug.log file and creating new one.\n"
		rm debug.log
		touch debug.log
	else
		echo -e "\n# Creating new debug.log file"
		touch debug.log
	fi
else
	echo -e "\n#Debug is not on."
fi
}

## Generate daily dummy Data
gen_dummydata ()
{
	if [ "$debugVal" -eq 1 ] ; then echo -e "Day $num_days_count"; fi

# set SMG value - used to along with IMSI, start_date anddt_timestamp to generate a hash
smgVal=0

## Define the starting entry for each KPI line
line_start="$imsival|${DATE_RANGE_ARRAY[$num_days_count]}|{\"metricId\":\"ibmaaf_bytestotal_by_cell_sitename\",\"counters\":["
	# if [ "$debugVal" -eq 1 ]; then echo -e "\nLine start =$line_start" ; else echo -e "$line_start">> debug.log; fi
line_mid="{\"metricId\":\"ibmaaf_bytestotal\",\"counters\":["
	# if [ "$debugVal" -eq 1 ]; then echo -e "\nLine mid =$line_mid" ; else echo -e "$line_mid">> debug.log; fi
line_end="{\"metricId\":\"ibmaaf_set_cesaggregation_video_by_cell\",\"counters\":["
	# if [ "$debugVal" -eq 1 ]; then echo -e "\nLine end =$line_end" ; else echo -e "$line_end">> debug.log; fi
	if [ "$debugVal" -eq 1 ]; then echo -e "\nLine start: $line_start \nLine mid: $line_mid \nLine end:$line_end">> debug.log; fi

## for each site, generate a 1 line entry for each KPI. append counter details for each site to line_start
# echo "num_days = $num_days"

num_sites_count=0
bytes_per_site_array_point=$num_days_count # used to move array location value on by 31 for each location value
let site_array_count="$SITES_ARRAY_last_index_val -1" # reduced by 1 as final entry has a differnent format handled in (B) beliw

	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nsite array count = $site_array_count">> debug.log; fi

## (A) ibmaaf_bytestotal_by_cell_sitename
while [ $num_sites_count -lt $site_array_count ]
do
	line_start=$line_start"{\"breakdown\":\"${SITES_ARRAY[$num_sites_count]}\",\"value\":[${BYTE_PER_SITE_ARRAY[$bytes_per_site_array_point]}]},"
	
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nline_start now:\n$line_start">> debug.log; fi
	let "num_sites_count += 1"
	let "bytes_per_site_array_point += 31"
done

	# (B) Add last site+value entry less the "," - needed to correctly format the ibmaaf_bytestotal_by_cell_sitename entry
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nAdding last site & value less the \",\" to the end of:\n = $line_start">> debug.log; fi	
	line_start=$line_start"{\"breakdown\":\"${SITES_ARRAY[$num_sites_count]}\",\"value\":[${BYTE_PER_SITE_ARRAY[$bytes_per_site_array_point]}]}]}|"
	echo -e "\nline_start now:\n$line_start"
	
## (C) ibmaaf_bytestotal
line_mid=$line_mid"{\"value\":[${DAILY_BYTES_SITE[$num_days_count]}]}]}|"

	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLine mid now: $line_mid">> debug.log; fi
echo -e "\nline_mid now:\n$line_mid"

## Join existing start and mid line
tmp_joined_entry=${line_start}${line_mid}
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nline start + line mid = $tmp_joined_entry">> debug.log; fi

## (D) ibmaaf_set_cesaggregation_video_by_cell

#set counters
num_sites_count=0
bytes_per_site_array_point=$num_days_count # reset from above so it can be used to move array location value on by 31 for each CES score value
let site_array_count="$SITES_ARRAY_last_index_val -1" # reduced by 1 as final entry has a differnent format handled in (B) beliw

	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nbytes_per_site_array_point = $bytes_per_site_array_point\nnum_days_count = $num_days_count\nnum_sites_count = $num_sites_count\nsite_array_count = $site_array_count\n" >> debug.log; fi

while [ $num_sites_count -lt $site_array_count ]
do # generate the 5 CES score separate by ,'s for inclusion in the first 6 of 7 sites daily CES ratings - 7th site handled separately in (E) as it has a different end to the text
	cesValue="${VIDEO_CES_ARRAY[$bytes_per_site_array_point]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+31]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+62]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+93]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+124]}"
		if [ "$debugVal" -eq 1 ] ;  then echo -e "\nCESValue=$cesValue">> debug.log; fi
	
	let "bytes_per_site_array_point += 155"
	line_end=$line_end"{\"breakdown\":\"${SITES_ARRAY[$num_sites_count]}\",\"value\":[${cesValue}]},"
	
	# incremet counters
	let "num_sites_count += 1"	
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nline_end:\$line_endCESValue=$cesValue">> debug.log; fi
	
	# generate final CES score set to be used in E
	FinalcesValue="${VIDEO_CES_ARRAY[$bytes_per_site_array_point]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+31]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+62]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+93]},${VIDEO_CES_ARRAY[$bytes_per_site_array_point+124]}"
		if [ "$debugVal" -eq 1 ] ;  then echo -e "\nFinal ces value = $FinalcesValue">> debug.log; fi

done
		
# (E) Add last site values + time stamp and SGV value to complete the last line (less the ",") - needed to correctly format the ibmaaf_set_cesaggregation_video_by_cell entry
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nAdding last site & value less the \",\" to the end of:\n = $line_end">> debug.log; fi	
# Format the DT time stamp by removing the last 2 digits of the date timepstamp
tmp_date=${DATE_RANGE_ARRAY[$num_days_count]}
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\ntmp_date = $tmp_date">> debug.log; fi
	
dt_timestamp=${tmp_date:0:12}
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\ndt_timestamp = $dt_timestamp">> debug.log; fi
# Set sgn value
smgVal=0
	
line_end=$line_end"{\"breakdown\":\"${SITES_ARRAY[$num_sites_count]}\",\"value\":[${FinalcesValue}]}]}|$dt_timestamp|$smgVal"
echo -e "\nline_end now:\n$line_end"

## Join existing start and mid line with end line to complete the enryt
final_joined_entry=${tmp_joined_entry}${line_end}
echo -e "\n\nFinal line entry is:\n$final_joined_entry"
echo "$final_joined_entry" >> GeneratedJSON.csv
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************
## backup old files first
backup_old_files

# #Set variables to be used when calling the main function
num_days_count=0
#sqm_val=1 #SQM will be incremented from 1 up to the number of days the data is to be generated for. It is a hash function of IMSI it groups data into bucket-like partitions.

# #Generate Daily Dummy Data Set per day
while [ $num_days_count -lt $DATE_RANGE_ARRAY_last_index_val ] # run a loop to generate the values in a json file for each day
do
	let "tmpDayCount=$num_days_count+1"
	# if [ "$debugVal" -eq 1 ] ;  then echo -e "\nGenerating volume data for each day for day: $tmpDayCount">> debug.log; fi
	#echo "Day $tmpDayCount"
	gen_dummydata
	let "num_days_count += 1"
	# let "sqm_val += 1"
done

echo -e "\n***** Generation of dummy data per site per day finished **********"