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


