#
# helper methods
#

#
# print a message and exit
#
function report_and_exit {

   local MESSAGE=$1
   echo $MESSAGE
   exit 1
}

#
# print an error message and exit
#
function error_and_exit {

   local MESSAGE="ERROR: $1"
   report_and_exit "$MESSAGE"
}

#
# prints a banner around a message
#
function banner_message {
   # set local definitions
   local message=$1
   local banner=$(echo "$message" | sed -e 's/./-/g')

   echo "$banner"
   echo "$message"
   echo "$banner"
}

#
# end of file
#
