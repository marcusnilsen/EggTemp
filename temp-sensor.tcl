#---------------------------------------------------------------------------+
#                    TEMP SENSOR SCRIPT - MYSQL LOOKUP                      |
#                            2010 +-+ mables                                |
#                      https://github.com/mables                            |
#---------------------------------------------------------------------------+
# Todo:
# - Add ascii graph to show min/max temperatues
# - Check for decimals on low temp
# v1.2 11.11.2011
# - Added timestamp to max/min values
# v1.1 14.07.2011
# - Added temp stat trigger with min/max temperatures
# v1 2010
# - Created the initial script with only the !temp trigger/function.
#---------------------------------------------------------------------------+
#                Table structure for table temperatures                     |
#---------------------------------------------------------------------------+
# Field             | Type      | Null | Default                            |
#---------------------------------------------------------------------------+
# ID                | int(200)  | No   |                                    |
# timestamp         | timestamp | No   | CURRENT_TIMESTAMP                  |
# sensor            | int(11)   | No   |                                    |
# temperature       | float     | No   |                                    |
#-----------------------------CONFIG SECTION--------------------------------+

# Set up the DB variables
set mysqlPort ""
set mysqlHost ""
set mysqlUser ""
set mysqlPassword ""
set mysqlDb ""
set mysqlTable "temperatures"

# Show the latest temperature
set triggerTemp "!temp"
set triggerStat "!tempstat"


#----------------------------END OF CONFIG----------------------------------+

# External Pkgs needed
package require mysqltcl
# To get db status, include this:
global mysqlstatus

# Bindings -- Only for bot owner and partyline users!
bind pub p|n $triggerTemp pub:temp
bind pub p|n $triggerStat pub:stat

# Functions
proc pub:temp {nick uhost handle chan txt} {
        global mysqlHost
        global mysqlPort
        global mysqlUser
        global mysqlPassword
        global mysqlDb
        set mysqlHandler [mysqlconnect -host $mysqlHost -port $mysqlPort -user $mysqlUser -password $mysqlPassword -db $mysqlDb]

        set msgString " "

        # Get last temperature
        foreach temps [mysqlsel $mysqlHandler "SELECT t.temperature,ts.name FROM temperatures t,temperatures_sensors ts WHERE t.sensor_id=ts.id AND timestamp > NOW() - INTERVAL 6 MINUTE GROUP BY ts.name" -list] {
                set temperature [string range [lindex $temps 0] 0 3]
                set sensor [lindex $temps 1]

                if {$temperature>0} {
                        set temperature "\00304$temperature°C"
                } else {
                        set temperature "\00302$temperature°C"
                }

                # ADD the temp to array
                append msgString "\00300$sensor\003: $temperature\003 "

        }

        if {[string length $msgString] >= 17} {
                putserv "PRIVMSG $chan $msgString"
        }


        mysqlclose $mysqlHandler
        return 0
}

proc pub:stat {nick uhost handle chan txt} {
        global mysqlHost
        global mysqlPort
        global mysqlUser
        global mysqlPassword
        global mysqlDb
        set mysqlHandler [mysqlconnect -host $mysqlHost -port $mysqlPort -user $mysqlUser -password $mysqlPassword -db $mysqlDb]

        global highestTemp
        global lowestTemp
	set countloop 0

	foreach 24htemp [mysqlsel $mysqlHandler "(SELECT t.temperature as temp,DATE_FORMAT(t.timestamp,'%a %T') as time,ts.name as name FROM temperatures as t, temperatures_sensors as ts WHERE t.sensor_id=ts.id AND ts.id=1 AND t.timestamp > NOW() - INTERVAL 24 HOUR ORDER BY t.temperature DESC LIMIT 1) UNION ALL (SELECT t.temperature as temp,DATE_FORMAT(t.timestamp,'%a %T') as time,ts.name as name FROM temperatures as t, temperatures_sensors as ts WHERE t.sensor_id=ts.id AND ts.id=1 AND t.timestamp > NOW() - INTERVAL 24 HOUR ORDER BY t.temperature ASC LIMIT 1)" -list] {
		incr countloop
		set temp [string range [lindex $24htemp 0] 0 3]
		set time [lindex $24htemp 1]
		set sensor [lindex $24htemp 2]
		if {$countloop == 1} {
			set msgString "\00300$sensor\003: Last 24 hours, "
		}
		if {$countloop == 1} {
			if {$temp>0} {
				set maxtemp "\00304$temp°C"
			} else {
				set maxtemp "\00302$temp°C"
			}
			append msgString "max: $maxtemp\003 (\00300$time\003) "
		} elseif {$countloop == 2} {
			if {$temp>0} {
				set mintemp "\00304$temp°C"
			} else {
				set mintemp "\00302$temp°C"
			}
			append msgString "min: $mintemp\003 (\00300$time\003) "
		}
        }
         
        foreach allhigh [mysqlsel $mysqlHandler "SELECT DATE_FORMAT(t.timestamp, GET_FORMAT(DATE,'EUR')) AS time,t.temperature AS temp,ts.name FROM temperatures t,temperatures_sensors ts WHERE t.sensor_id=ts.id AND ts.id=1 ORDER BY t.temperature DESC LIMIT 1" -list] {
                set maxtime "\00300[lindex $allhigh 0]"
                set maxtemp "\00304[string range [lindex $allhigh 1] 0 3]°C"
                set maxsensor [lindex $allhigh 2]

                append msgString2 "\00300$maxsensor\003: All time high, max: $maxtemp \003($maxtime\003) "

        }

        foreach alllow [mysqlsel $mysqlHandler "SELECT DATE_FORMAT(t.timestamp, GET_FORMAT(DATE,'EUR')) AS time,t.temperature AS temp,ts.name FROM temperatures t,temperatures_sensors ts WHERE t.sensor_id=ts.id AND ts.id=1 ORDER BY t.temperature ASC LIMIT 1" -list] {
                set lowtime "\00300[lindex $alllow 0]"
                set lowtemp "\00302[string range [lindex $alllow 1] 0 4]°C"


                append msgString2 "  min: $lowtemp \003($lowtime\003)\003 "

        }

        if {[string length $msgString] >= 17} {
                putserv "PRIVMSG $chan $msgString"
        }
        if {[string length $msgString2] >= 17} {
                putserv "PRIVMSG $chan $msgString2"
        }
        # Get stats

        mysqlclose $mysqlHandler
        return 0
}


putlog "SQL-Temperature addon loaded"
