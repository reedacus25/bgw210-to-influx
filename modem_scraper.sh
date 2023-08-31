#!/bin/bash

#This script will parse the VDSL2 statistics from the Arris BGW210-700 RG
#and store them in an InfluxDB time series database.
#This script is tailored towards VDSL2 installs, not GPON/Fiber or ADSL[2+].
#I have not tested this script in a single-pair VDSL2 installation, YMMV.

#At some point, ATT added 2 lines to their RG page, breaking the stats.
#Considered fixed in 4.23.4

#~~It has been tested working against the following firmware revisions:~~
#1.10.9
#1.9.16
#1.8.18

#It is known to *NOT* work with firmware versions including and prior to:
#1.5.12

#This script is written in bash, and has the following dependencies
#curl
#wget
#findutils

#while this script doesn't depend on influxdb being installed where this is run,
#this script assumes you have an existing influxdb environment and database for storing data.

#general concept is that you know the line number of the metric you want
#head the number of lines to include the line you want
#tail 1 line to get the line you want
#cut to get the value you want
#pass through xargs to clean the data
#store all of this in a variable to pass to influxdb

#I recommend running this in cron, at whichever interval you prefer.

#Legend:
#DS = Downstream
#US = Upstream
#L1 = Line 1
#L2 = Line 2

#set location for where to pull the stats down to
workdir=/tmp
statsfile=broadbandstatistics.ha

#set influxdb location info
influxserver=localhost
influxport=8086
influxdbname=uverse

#pull down the stats file to working directory and set variable to the stats file
modemaddress=192.168.1.254
modemstatspath="cgi-bin/broadbandstatistics.ha"
wget http://$modemaddress/$modemstatspath  -O $workdir/$statsfile
html=$workdir/$statsfile

#command to post to influxdb
post2influx="curl -i -XPOST "http://$influxserver:$influxport/write?db=$influxdbname" --data-binary"

#comments for 'variableName - lineNumber'

#VDSL2 Line Sync Rates
#line1syncDS - 161
line1syncDS=$(head -n160 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=sync_ds value='$line1syncDS
#line2syncDS - 162
line2syncDS=$(head -n161 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=sync_ds value='$line2syncDS
#line1syncUS - 165
line1syncUS=$(head -n164 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=sync_us value='$line1syncUS
#line2syncUS - 166
line2syncUS=$(head -n165 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=sync_us value='$line2syncUS
#line1maxDS - 169
line1maxDS=$(head -n168 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=max_ds value='$line1maxDS
#line2maxDS - 170
line2maxDS=$(head -n169 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=max_ds value='$line2maxDS
#line1maxUS - 173
line1maxUS=$(head -n172 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=max_us value='$line1maxUS
#line2maxUS - 174
line2maxUS=$(head -n173 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=max_us value='$line2maxUS
#bothsyncDS - 378
bothsyncDS=$(head -n377 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Both,type_instance=sync_ds value='$bothsyncDS
#bothsyncUS - 382
bothsyncUS=$(head -n381 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Both,type_instance=sync_us value='$bothsyncUS

#line1snrDS - 192
line1snrDS=$(head -n191 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line1,type_instance=ds value='$line1snrDS
#line1snrUS - 195
line1snrUS=$(head -n194 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line1,type_instance=us value='$line1snrUS
#line2snrDS - 198
line2snrDS=$(head -n197 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line2,type_instance=ds value='$line2snrDS
#line2snrUS - 201
line2snrUS=$(head -n200 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line2,type_instance=us value='$line2snrUS

#line1attenDS - 206
line1attenDS=$(head -n205 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line1,type_instance=ds value='$line1attenDS
#line1attenUS - 209
line1attenUS=$(head -n208 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line1,type_instance=us value='$line1attenUS
#line2attenDS - 212
line2attenDS=$(head -n211 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line2,type_instance=ds value='$line2attenDS
#line2attenUS - 215
line2attenUS=$(head -n214 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line2,type_instance=us value='$line2attenUS

#line1powerDS - 220
line1powerDS=$(head -n219 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line1,type_instance=ds value='$line1powerDS
#line1powerUS - 222
line1powerUS=$(head -n212 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line1,type_instance=us value='$line1powerUS
#line2powerDS - 224
line2powerDS=$(head -n223 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line2,type_instance=ds value='$line2powerDS
#line2powerUS - 226
line2powerUS=$(head -n225 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line2,type_instance=us value='$line2powerUS

#line1fecDS - 260
line1fecDS=$(head -n259 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=fec_ds value='$line1fecDS
#line1fecUS - 262
line1fecUS=$(head -n261 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=fec_us value='$line1fecUS
#line2fecDS - 264
line2fecDS=$(head -n263 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=fec_ds value='$line2fecDS
#line2fecUS - 266
line2fecUS=$(head -n265 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=fec_us value='$line2fecUS

#line1crcDS - 270
line1crcDS=$(head -n269 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=crc_ds value='$line1crcDS
#line1crcUS - 272
line1crcUS=$(head -n271 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=crc_us value='$line1crcUS
#line2crcDS - 274
line2crcDS=$(head -n273 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=crc_ds value='$line2crcDS
#line2crcUS - 276
line2crcUS=$(head -n275 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=crc_us value='$line2crcUS

#line1errsec15m - 294
line1errsec15m=$(head -n293 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=Errored_Seconds value='$line1errsec15m
#line2errsec15m - 300
line2errsec15m=$(head -n299 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=Errored_Seconds value='$line2errsec15m
#line1errsecsev15m - 307
line1errsecsev15m=$(head -n306 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=Severely_Errored_Seconds value='$line1errsecsev15m
#line2errsecsev15m - 313
line2errsecsev15m=$(head -n312 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=Severely_Errored_Seconds value='$line2errsecsev15m
#line1unavail15m - 320
line1unavail15m=$(head -n319 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=Unavailable_Seconds value='$line1unavail15m
#line2unavail15m - 326
line2unavail15m=$(head -n325 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=Unavailable_Seconds value='$line2unavail15m

#line1fec15m - 333
line1fec15m=$(head -n332 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=FEC value='$line1fec15m
#line2fec15m - 339
line2fec15m=$(head -n338 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=FEC value='$line2fec15m
#line1crc15m - 346
line1crc15m=$(head -n345 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=CRC value='$line1crc15m
#line2crc15m - 352
line2crc15m=$(head -n351 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=CRC value='$line2crc15m

#cleanup the statsfile
rm $html
