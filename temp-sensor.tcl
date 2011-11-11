#---------------------------------------------------------------------------+
#                    TEMP SENSOR SCRIPT - MYSQL LOOKUP                      |
#                            2010 +-+ mables                                |
#                      https://github.com/mables                            |
#---------------------------------------------------------------------------+

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

# Bindings
bind pub - $triggerTemp pub:temp
bind pub - $triggerStat pub:stat

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
        foreach temps [mysqlsel $mysqlHandler "SELECT t.temperature,ts.name FROM temperatures t,temperatures_sensors ts WHERE t.sensor_id=ts.id AND timestamp > NOW() - INTERVAL 6 MINUTE GROUP BY ts.name$
                set temperature [lindex $temps 0]
                set sensor [lindex $temps 1]

                if {$temperature>=0} {
                        set temperature "\00304[lindex $temps 0]°C"
                } else {
                        set temperature "\00302[lindex $temps 0]°C"
                }

                # ADD the temp to array
                append msgString "\003$sensor: $temperature\003 "

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
        
        # Get stats

        mysqlclose $mysqlHandler
        return 0
}

putlog "SQL-Temperature addon loaded"
