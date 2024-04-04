#!/bin/sh

# Replace <REDIS_PORT> and <REDIS_PASSWORD> with actual values
# Do not forget to change permissions to be more restrictive
redis-cli -p "<REDIS_PORT>" --pass "<REDIS_PASSWORD>" ping | grep "PONG"
