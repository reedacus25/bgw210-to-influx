# bgw210-to-influx

This script will parse the VDSL2 statistics from the Arris BGW210-700 RG  
and store them in an InfluxDB time series database.  
This script is tailored towards VDSL2 installs, not GPON/Fiber or ADSL[2+].  
I have not tested this script in a single-pair VDSL2 installation, YMMV.

It has been tested working against the following firmware revisions:  
•1.10.9   
•1.9.16   
•1.8.18   

It is known to *NOT* work with firmware versions including and prior to:  
•1.5.12

This script is written in bash, and has the following dependencies  
•curl  
•wget  
•findutils  
Obviously bash isn't the worlds best scripting language,  
however it provides a lower barrier to entry than a scripting language,  
and bash is what I was comfortable with when creating this.

while this script doesn't depend on influxdb being installed where this is run,  
this script assumes you have an existing influxdb environment and database for storing data.

The general concept is that you know the line number of the metric you want  
head the number of lines to include the line you want  
tail 1 line to get the line you want  
cut to get the value you want  
pass through xargs to clean the data  
store all of this in a variable to pass to influxdb.

I recommend running this in cron, at whichever interval you prefer.
