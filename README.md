Log onto the CCI VM (xxx in this case) as root/ibmgsc

PREPARATION:
============
Copy the required scripts and data to the VM using Filezilla or some other secure ftp client. I copied the originals to the /root/cciImage/share location

Scripts: 
o import_metrics.sh - import the historical metrics to the tnf.hrcc_historical_d_1 table
o test_metrics_import.sh - check the historical metrics import worked by testing the API
o import_subscriberprof.sh - import the subscriber profile into the tnf.hrcc_subscriber table
o test_subscriberpro_import.sh - check the subscriber profile import worked by testing the API
o test_all_import.sh - tests returning of both the metrics data and the subscriber profile data

Data Files:
o GeneratedJSON.csv - contains historical data metrics for the IMSI 272211221122333 between the dates 20171016000000 (16th Oct 2017) and 20171115000000 (15th Nov. 2017)
o subscriber_profile.csv - the subscriber profile data for IMSI 272211221122333

Next ensure the files are in unix format. If not, use the dos2unix utility to convert them or edit them with vi and run :set ff=unix. There may be some manual editing to be done e.g. rogue ,'s to be removed. Give the files a visual once over to check them.

Get the docker image ID by running: 

	[root@docker2 share]# docker ps

you should get something akin to the following returned:

	CONTAINER ID IMAGE         COMMAND                CREATED            STATUS            PORTS                  NAMES
	ddc41703a861 cas-demo-flat "/docker-entrypoint.s" About a minute ago Up About a minute 0.0.0.0:7000-7001->7000-7001/tcp, 0.0.0.0:7199->7199/tcp, 0.0.0.0:8009->8009/tcp, 0.0.0.0:8449->8449/tcp, 0.0.0.0:9042->9042/tcp, 0.0.0.0:9160->9160/tcp   sad_leakey

In this case ddc41703a861 is the ID we need. Copy the required files to the docker image as follows:

	[root@docker2 share]# docker cp <FILE> <CONTAINER ID>:/<LOCATION>/

	In this case I ran 
		[root@docker2 share]# docker cp import_subscriberprof.sh ddc41703a861:/home/boss/
		[root@docker2 share]# docker cp subscriber_profile.csv ddc41703a861:/home/boss/
		etc..

next open a bash session in docker by running:

		[root@docker2 share]# docker exec -it ddc41703a861 bash (replace the ID with your versions ID)
	and then
		cd /home/boss
	
	you should see your shell prompt change to something akin to 

	root@ddc41703a861:/home/boss#

list all the files to ensure they were successfully copied over to the docker image. I see 
	root@ddc41703a861:/home/boss# ls -l
	total 64
	-rwxr-xr-x. 1 root root 29553 Oct 31 15:08 GeneratedJSON.csv
	-rwxr-xr-x. 1 root root   162 Oct 20 21:20 import_metrics.sh
	-rwxr-xr-x. 1 root root   158 Oct 31 14:53 import_subscriberprof.sh
	-rwxr-xr-x. 1 root root   693 Oct 31 15:36 subscriber_profile.csv
	-rw-r--r--. 1 boss boss   279 Oct 31 15:58 test.cookie
	-rwxrwxrwx. 1 boss boss   272 May 24 12:25 test.sh
	-rwxr-xr-x. 1 root root   387 Oct 31 15:09 test_all_import.sh
	-rwxr-xr-x. 1 root root   272 Oct 21 12:10 test_metrics_import.sh
	-rwxr-xr-x. 1 root root   218 Oct 31 15:12 test_subscriberpro_import.sh
	root@ddc41703a861:/home/boss#

IMPORTING DATA:
===============
Import the subscriber profile details...
	root@ddc41703a861:/home/boss# bash ./import_subscriberprof.sh ./subscriber_profile.csv
	You will see the following returned....
	
		Using 3 child processes
		Starting copy of tnf.hrcc_subscriber with columns [imsi, msisdn, age, gender, handset, last_updaname, surname, date_of_birth, address_1, address_2, ethnicity, highest_level_of_education, emplo tenure, credit_rating_grade, monthly_arpu, customer_type, churned_flag, brand, fixmobilebundlef
		Processed: 1 rows; Rate:       2 rows/s; Avg. rate:       2 rows/s
		1 rows imported from 1 files in 0.416 seconds (0 skipped).
		root@ddc41703a861:/home/boss# 


Import the historical metrics data
	root@ddc41703a861:/home/boss# bash ./import_metrics.sh ./GeneratedJSON.csv
	you'll see 
		Using 3 child processes
		Starting copy of tnf.hrcc_historical_d_1 with columns [imsi, timeid, ibmaaf_bytestotal_by_cell_s
		Processed: 31 rows; Rate:      54 rows/s; Avg. rate:      80 rows/s
		31 rows imported from 1 files in 0.387 seconds (0 skipped).
		
CHECK THE IMPORT WORKED:
========================
Kick off a cqlsh session and run the following:
	
	root@ddc41703a861:/home/boss# cqlsh
	Connected to Test Cluster at 127.0.0.1:9042.
	[cqlsh 5.0.1 | Cassandra 3.0.9 | CQL spec 3.4.0 | Native protocol v4]
	Use HELP for help.
	cqlsh> use tnf;
	cqlsh:tnf> describe tables;

	hrcc_subscriber  hrcc_msisdn_imsi       hrcc_historical_d_1  flyway_info
	cas_properties   hrcc_historical_min_5  hrcc_historical_h_1
	
	check the sub profile import was successful...
	
		cqlsh:tnf> select * from hrcc_subscriber;

		imsi| account_number | address_1| address_2 | age | brand | car_owneate_group_name | credit_rating_grade | customer_type | customer_value | data_offering | d | first_name | fixmobilebundleflag | gender | handset  | highest_level_of_education | last_upda plan | plan_name | sms_offering | subscriber_name | surname | tenure | voice_offering
		-----------------+----------------+-----------------------+------------+------+-------+------------------------+---------------------+-----------------+----------------+--------------------+---+------------+---------------------+--------+----------+----------------------------+----------------+-----------+--------------+-----------------+---------+--------+----------------
		272211221122333 |      964347550 | 1177 S. Beltline Road | Coppel, TX | null |  null |      nulteady - Family |                null | Consumer Mobile |           null | 4G All You Can Eat |   |       Paul |                null |      M | iPhone 7 |            Bachelor Degree | 201709311 null |      null |         null |            null |   Kelly |   null |           null
	 
	check the historical data import was successful....
	
		cqlsh:tnf> select * from hrcc_historical_d_1;
		dt| sgm | imsi| timeid| ibmaaf_bytestotal|ibmaaf_bytestotal_b|ibmaaf_bytestotal_by_cell_sitename| ibmaaf_bytestotbmaaf_bytestotal_geran_topapps | ibmaaf_bytestotal_utran_topapps........
		
		lots of results will be returned e.g 
		
		201710210000 |   0 | 272211221122333 | 20171021000000 |  {"metricId":"ibmaaf_bytestotal","counters":[{"value":[71055808]}]} | null |                     {"metricId":"ibmaaf_bytestotal_by_cell_sitename","counters":[{"breakdown":"Belt Line Road","value":[3991158]},{"breakdown":"Las Colinas","value":[4601464]},{"breakdown":"Irving","value":[22556593]},{"breakdown":"Valley Ranch","value":[31732031]},{"breakdown":"Market Center","value":[0]},{"breakdown":"West Dallas","value":[0]},{"breakdown":"Cockrell Hill","value":[0]}]} |                        null |                     null |                             null |  
		

CHECK THE API CALL RETURNS THE CORRECT RESULTS:
===============================================
Run the scripts as follows:

	root@ddc41703a861:/home/boss# ./test_metrics_import.sh
	
  which should return something akin to
	
	{"token":":Ym9zcw:ez89k:rhIpZRyNHGMeFMAorQuCqLVycDzVy2mRYmqc80s4lU3Wom5pJ9OgkqHEugamf_So-NnAMtxwOo5vN8f7FloX8w"}	[{"imsi":"272211221122333","time":"20171103000000","metrics":[{"metricId":"ibmaaf_bytestotal","counters":[{"value":[113876826]}]},{"metricId":"ibmaaf_bytestotal_by_cell_sitename","counters":[{"breakdown":"Belt Line Road","value":[3462197]},{"breakdown":"Las Colinas","value":[2389562]},{"breakdown":"Irving","value":[9170138]},{"breakdown":"Valley Ranch","value":[2920650]},{"b...
	etc
	
	root@ddc41703a861:/home/boss# ./test_subscriberpro_import.sh
	
  which should return something akin to
	
	{"token":":Ym9zcw:ez89l:xxwZcBBDhVZ73XKCMYXVtRDNdjlkBcn3zG44a-267fBBR621uznoXqPiUaPJvpWctqNWhy3_tUbBiht4ix1pVg"}
	[{"imsi": "272211221122333", "account_number": "964347550", "address_1": "1177 S. Beltline Road", "address_2": "Coppel, TX", "age": null, "brand": null, "car_owner": null, "churned_flag": "LOW", "contract": null, "contract_type": "Bill Pay", "corporate_account_name": "Early Adopter, LTV High", "corporate_group_name": "Steady - Family", "credit_rating_grade": null, "customer_type": "Consumer Mobile", "customer_value": null, "data_offering": "4G All You Can Eat", "date_of_birth": null, "dob": "LOW", "employment_status": null, "estimated_income": nul....
	etc

	or check everything is returned:
	
	root@ddc41703a861:/home/boss# ./test_all_import.sh
	{"token":":Ym9zcw:ez89m:L3uqwghJpL7Ti0UTyjAMyrEtirHmTPI9csy90odP9-31V3DWxiOvMS2vrdKRZMX36rJPLcrVPaxgDibEHWWwLA"}
	[{"imsi":"272211221122333","time":"20171027000000","metrics":[{"metricId":"ibmaaf_bytestotal","counters":....
	etc
	.
	]}]
	[{"imsi": "272211221122333", "account_number": "964347550", "address_1": "1177 S. Beltline Road", "address_2": "Coppel, TX", "age": null, "brand": null, "car_owner": null, "churned_flag": "LOW", "contract": null, "contract_t
	etc
	..
	: null}]
	
	
	____________________________________________________________________

Some notes on the Cassandra docker image from Eng:

The usual RHEL configs are used for network, IP is set in /etc/sysconfig/network-scripts/ifcfg-enp0s3:
 
TYPE="Ethernet"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"cql -e "copy tnf.test from 'test-load.txt' with header=true and delimiter='|'"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="enp0s3"
UUID="3ca8a20f-a2f8-4b67-8ca7-852dd38eb23f"
DEVICE="enp0s3"
ONBOOT="yes"
IPADDR="172.30.9.249"
PREFIX="24"
IPV6_PEERDNS="yes"
IPV6_PEERROUTES="yes"
 

1. Cassandra DB configuration file location is: /opt/cassandra/cassandra.yaml.custom
   I do not think that any changes required in cassandra db.
 
2. Web server configuration file locations is: /opt/tnf/apps/cas-main-var/cfg-cas.properties
    The 'webserver.port' value may be change as required per network set up.
 
3. The csv data may be loaded using cqlsh (Cassandra query language shell).
    This utility is shipped with any cassandra distributive.
 
 
In /home/boss/bin or /root/hrccwithdata/docker/home/boss directory a script to run cqlsh was created

CQLSH_HOST=node1 /usr/lib/cassandra/bin/cqlsh -u cassandra -p cassandra "$@"
 
In order to load data using this utility csv file with header should not include # at first line like we usually do in provisioning.
 
Example of loading data to cassandra table:
 
test-load.cql:
 
use tnf;
drop table if exists test;
create table test (test int primary key, name text);
copy test from 'test-load.txt' with header=true and delimiter='|';
select * from test;
 
test-load.txt
 
test|name
1|first
 
$/home/bin/cql -f test-load.cql
 
The output should look:
 
[boss@hrcc ~]$ ./test-load.sh
  Using 1 child processes
  Starting copy of tnf.test with columns [test, name].
  Processed: 1 rows; Rate:       0 rows/s; Avg. rate:       1 rows/s
  1 rows imported from 1 files in 1.130 seconds (0 skipped).
    test | name
    ------+-------
    1 | first
   (1 rows)
 
 
if table already exists then one can start import with one liner:
 
[boss@hrcc ~]$ cql -e "copy tnf.test from 'test-load.txt' with header=true and delimiter='|'"
 
Using 1 child processes
Starting copy of tnf.test with columns [test, name].
Processed: 1 rows; Rate:       1 rows/s; Avg. rate:       2 rows/s
1 rows imported from 1 files in 0.557 seconds (0 skipped).
 

The amount of data loaded with this command should not be too big
 
If network is set up correctly the cqlsh utilty may be invoked outside of the VM, for instance
download cassandra
wget http://ftp.heanet.ie/mirrors/www.apache.org/dist/cassandra/3.0.13/apache-cassandra-3.0.13-bin.tar.gz
tar xvfz apache-cassandra-3.0.13-bin.tar.gz
cd apache-cassandra-3.0.13/bin
CQLSH_HOST=172.30.9.249 ./cqlsh -u cassandra -p cassandra -e 'select * from tnf.test limit 1'
 
Use IP address assigned to vm istead of 172.30.9.249.
 
 
I tested the import export from csv, and in order to load data one have to increase batch size in
/opt/cassandra/cassandra.yaml.custom file.
 
The following two lines should set big enough batch size
 
batch_size_fail_threshold_in_kb: 5000
batch_size_warn_threshold_in_kb: 500
 
 
Then one can load data from pipe separated files. The example files attached to this email.
 
In the attached file I put cas_properties.txt these properties make hrcc properties persistent, by default some properties expire.
 
The command to load cas_properties into cassandra db is:
 
  cqlsh -e "copy tnf.cas_properties from 'cas_properties.txt' with header=true and delimiter='|'"
 
The same way one can import pipe separated data into historical tables:
 
  cqlsh -e "copy tnf.hrcc_historical_h_1 from 'hrcc_historical_h_1.txt' with header=true and delimiter='|'"

I imported your csv with my script '/share/import.sh' which is:
 
  i=$1
  columns=$(head -n 1 $i | tr '|' ',')
  cqlsh -e "copy tnf.hrcc_historical_d_1 ($(echo $columns))  from '$(echo $i)'   with header = true and delimiter = '|'"
 
 
I added a local directory 'share' which should be mounted by run.sh command to /share in docker container.
Right now import.sh and your csv stored in shared directory.
 
 
in order to run my import.sh script first run docker image and switch to docker container:
 
  docker exec -it cas-demo-flat bash
 
  #cd /root/cciImage/share
  root@3d9790afc534:/share# ./import.sh BytestotalByAppsAndSites_DummyData-DAILY.csv

The output looks like this:
 
root@3d9790afc534:/share# ./import.sh BytestotalByAppsAndSites_DummyData-DAILY.csv
  Using 16 child processes
  Starting copy of tnf.hrcc_historical_d_1 with columns [imsi, timeid, ibmaaf_bytestotal_by_cell_sitename, ibmaaf_bytestotal_by_application, dt, sgm].
  Processed: 40 rows; Rate:      71 rows/s; Avg. rate:     104 rows/s
  40 rows imported from 1 files in 0.385 seconds (0 skipped).
 
I checked input size and it was 40 lines:
  root@3d9790afc534:/share# wc -l BytestotalByAppsAndSites_DummyData-DAILY.csv
  41 BytestotalByAppsAndSites_DummyData-DAILY.csv
  #exit
 
In order to delete all data from table one can run a command from outside of docker command prompt
 
  docker exec cas-demo-flat cqlsh -e 'truncate tnf.hrcc_historical_h_1'
