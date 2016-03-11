#!/bin/bash
# 
# check_rabbitmq_consumers.sh
# https://github.com/sol1/icinga-check-rabbitmq
# 
# Standard Icinga return codes
E_SUCCESS="0"
E_WARNING="1"
E_CRITICAL="2"
E_UNKNOWN="3"

usage() {
	cat << EOU
Usage: $0 <OPTIONS>
	-u <RabbitMQ API username>
	-p <RabbitMQ API password> 
	-a <API URL, e.g. http://localhost:15672/api/overview>
	-c <Minimum number of messages to go CRITICAL>
	-w <Minimum number of messages to go WARNING>

Example:
	$0 -u guest -p guest -a "http://localhost:15672/api/overview" -c 1000 -w 500
EOU
	exit ${E_UNKNOWN}
}

while getopts ":u:p:a:q:c:w:" o; do
    case "${o}" in
        u)
            u=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ;;
        a)
            a=${OPTARG}
            ;;
        c)
            c=${OPTARG}
            ;;
        w)
            w=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${u}" ] || [ -z "${p}" ] || [ -z "${a}" ] || [ -z "${c}" ] || [ -z "${w}" ]; then
	usage
fi

curl=`which curl`
jq=`which jq`

if [ -z "${curl}" ] || ! [ -x "${curl}" ]; then
	echo "UNKNOWN: curl not found"
	exit ${E_UNKNOWN}
fi

if [ -z "${jq}" ] || ! [ -x "${jq}" ]; then
	echo "UNKNOWN: jq not found"
	exit ${E_UNKNOWN}
fi

response=`curl -s -u $u:$p -o - "$a"`

# Check for a simple error provided by the API
api_error=`echo $response | jq ".error?"`

if ! [ -z "${api_error}" ] && [ "${api_error}" != "null" ]; then
	echo "CRITICAL: API returned: ${api_error}"
	exit ${E_CRITICAL}
fi

if [ $? != 0 ]; then
	echo "CRITICAL: Bad response from RabbitMQ HTTP API"
	exit ${E_CRITICAL}
else
	messages=`echo $response | jq ".queue_totals.messages"`
fi

if [ -z "${messages}" ]; then
	echo "CRITICAL: No response from RabbitMQ HTTP API"
	exit ${E_CRITICAL}
fi

if [ $messages -ge $c ]; then
	echo "CRITICAL: ${messages} messages queued"
	exit ${E_CRITICAL}
fi

if [ $messages -ge $w ]; then
	echo "WARNING: ${messages} messages queued"
	exit ${E_WARNING}
fi

if [ $messages -lt $w ]; then
	echo "OK: ${messages} messages queued"
	exit ${E_SUCCESS}
fi

exit ${E_UNKNOWN}
