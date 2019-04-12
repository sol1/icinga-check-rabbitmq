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
	-a <API URL, e.g. http://localhost:15672/api/consumers>
	-q <RabbitMQ queue name, e.g. remote_deliveries>
	-c <Number of consumers when CRITICAL or less>
	-w <Number of consumers when WARNING or less>

Example:
	$0 -u guest -p guest -a "http://localhost:15672/api/consumers" -q remote_deliveries -c 1 -w 2
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
        q)
            q=${OPTARG}
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

if [ -z "${u}" ] || [ -z "${p}" ] || [ -z "${a}" ] || [ -z "${q}" ] || [ -z "${c}" ] || [ -z "${w}" ]; then
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
if [ -z "$response" ]; then
	api_error=`echo $response | jq ".error?"`
else
	api_error='';
fi

if ! [ -z "${api_error}" ]; then
	echo "CRITICAL: API returned: ${api_error}"
	exit ${E_CRITICAL}
fi

if [ $? != 0 ]; then
	echo "CRITICAL: Bad response from RabbitMQ HTTP API"
	exit ${E_CRITICAL}
else
	consumers=`echo $response | jq "map(select(.queue.name == \"$q\")) | length"`
fi

if [ -z "${consumers}" ]; then
	echo "CRITICAL: No response from RabbitMQ HTTP API"
	exit ${E_CRITICAL}
fi

if [ $consumers -gt $w ]; then
	echo "OK: ${q} has ${consumers} consumers"
	exit ${E_SUCCESS}
fi

if [ $consumers -le $c ]; then
	echo "CRITICAL: ${q} has ${consumers} consumers"
	exit ${E_CRITICAL}
fi

if [ $consumers -le $w ]; then
	echo "WARNING: ${q} has ${consumers} consumers"
	exit ${E_WARNING}
fi

exit ${E_UNKNOWN}
