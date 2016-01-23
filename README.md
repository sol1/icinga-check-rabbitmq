# icinga-check-rabbitmq

Some lightweight Nagios/Icinga check plugins for RabbitMQ.

## Status

Unreleased; not yet suitable for any use.

## Checks

The following types of checks are currently supported:

 * None

## Requirements

The basic check logic is written in bash. Checks rely on the HTTP API provided
by the RabbitMQ management interface and also depend on having the following
utilities in your `$PATH`:

 * [curl](http://curl.haxx.se/)
 * [jq](https://stedolan.github.io/jq/)

## TODO

 * Number of consumers on a queue
 * TODO
