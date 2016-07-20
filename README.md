# icinga-check-rabbitmq

Some lightweight Nagios/Icinga check plugins for RabbitMQ.

## Checks

The following checks are included:

 * `check_rabbitmq_consumers.sh`: Number of consumers on a queue

## Requirements

The basic check logic is written in bash. Checks rely on the HTTP API provided
by the RabbitMQ management interface, so the `rabbitmq-management` plugin must
be enabled and the API accessible from the machine you intend to run the check
from (probably localhost).

You also need the following utilities in your `$PATH`:

 * [curl](http://curl.haxx.se/)
 * [jq](https://stedolan.github.io/jq/) version 1.5 or above

## TODO

 * TODO
