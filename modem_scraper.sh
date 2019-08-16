#!/bin/bash

#This script will parse the VDSL2 statistics from the Arris BGW210-700 RG
#and store them in an InfluxDB time series database.
#This script is tailored towards VDSL2 installs, not GPON/Fiber or ADSL[2+].
#I have not tested this script in a single-pair VDSL2 installation, YMMV.

#It has been tested working against the following firmware revisions:
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
#line1syncDS - 159
line1syncDS=$(head -n158 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=sync_ds value='$line1syncDS
#line2syncDS - 160
line2syncDS=$(head -n159 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=sync_ds value='$line2syncDS
#line1syncUS - 163
line1syncUS=$(head -n162 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=sync_us value='$line1syncUS
#line2syncUS - 164
line2syncUS=$(head -n163 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=sync_us value='$line2syncUS
#line1maxDS - 167
line1maxDS=$(head -n166 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=max_ds value='$line1maxDS
#line2maxDS - 168
line2maxDS=$(head -n167 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=max_ds value='$line2maxDS
#line1maxUS - 171
line1maxUS=$(head -n170 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line1,type_instance=max_us value='$line1maxUS
#line2maxUS - 172
line2maxUS=$(head -n171 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Line2,type_instance=max_us value='$line2maxUS
#bothsyncDS - 376
bothsyncDS=$(head -n375 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Both,type_instance=sync_ds value='$bothsyncDS
#bothsyncUS - 380
bothsyncUS=$(head -n379 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'sync_rate,instance=Both,type_instance=sync_us value='$bothsyncUS

#VDSL2 Line SNR values
#line1snrDS - 190
line1snrDS=$(head -n189 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line1,type_instance=ds value='$line1snrDS
#line1snrUS - 193
line1snrUS=$(head -n192 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line1,type_instance=us value='$line1snrUS
#line2snrDS - 196
line2snrDS=$(head -n195 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line2,type_instance=ds value='$line2snrDS
#line2snrUS - 199
line2snrUS=$(head -n198 $html | tail -n1 | xargs)
$post2influx 'sn_margin,instance=Line2,type_instance=us value='$line2snrUS

#VDSL2 Line Attenuation values
#line1attenDS - 204
line1attenDS=$(head -n203 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line1,type_instance=ds value='$line1attenDS
#line1attenUS - 207
line1attenUS=$(head -n206 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line1,type_instance=us value='$line1attenUS
#line2attenDS - 210
line2attenDS=$(head -n209 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line2,type_instance=ds value='$line2attenDS
#line2attenUS - 213
line2attenUS=$(head -n212 $html | tail -n1 | xargs)
$post2influx 'attenuation,instance=Line2,type_instance=us value='$line2attenUS

#VDSL2 Line Upstream/Downstream Power Level values
#line1powerDS - 218
line1powerDS=$(head -n217 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line1,type_instance=ds value='$line1powerDS
#line1powerUS - 220
line1powerUS=$(head -n219 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line1,type_instance=us value='$line1powerUS
#line2powerDS - 222
line2powerDS=$(head -n221 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line2,type_instance=ds value='$line2powerDS
#line2powerUS - 224
line2powerUS=$(head -n223 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'power_levels,instance=Line2,type_instance=us value='$line2powerUS

#VDSL2 Line Forward Error Correction values
#line1fecDS - 258
line1fecDS=$(head -n257 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=fec_ds value='$line1fecDS
#line1fecUS - 260
line1fecUS=$(head -n259 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=fec_us value='$line1fecUS
#line2fecDS - 262
line2fecDS=$(head -n261 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=fec_ds value='$line2fecDS
#line2fecUS - 264
line2fecUS=$(head -n263 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=fec_us value='$line2fecUS

#VDSL2 Line CRC Error values
#line1crcDS - 268
line1crcDS=$(head -n267 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=crc_ds value='$line1crcDS
#line1crcUS - 270
line1crcUS=$(head -n269 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line1,type_instance=crc_us value='$line1crcUS
#line2crcDS - 272
line2crcDS=$(head -n271 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=crc_ds value='$line2crcDS
#line2crcUS - 274
line2crcUS=$(head -n273 $html | tail -n1 | cut -d\< -f1 | xargs)
$post2influx 'errors_total,instance=Line2,type_instance=crc_us value='$line2crcUS

#VDSL2 Line Errored Seconds
#line1errsec15m - 292
line1errsec15m=$(head -n291 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=Errored_Seconds value='$line1errsec15m
#line2errsec15m - 298
line2errsec15m=$(head -n297 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=Errored_Seconds value='$line2errsec15m
#line1errsecsev15m - 305
line1errsecsev15m=$(head -n304 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=Severely_Errored_Seconds value='$line1errsecsev15m
#line2errsecsev15m - 311
line2errsecsev15m=$(head -n310 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=Severely_Errored_Seconds value='$line2errsecsev15m
#line1unavail15m - 318
line1unavail15m=$(head -n317 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line1,type_instance=Unavailable_Seconds value='$line1unavail15m
#line2unavail15m - 324
line2unavail15m=$(head -n323 $html | tail -n1 | cut -d\> -f2 | cut -d\< -f1 | xargs)
$post2influx 'errors_15m,instance=Line2,type_instance=Unavailable_Seconds value='$line2unavail15m


#cleanup the statsfile
rm $html
