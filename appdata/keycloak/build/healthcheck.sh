#!/bin/bash
# Modified from https://github.com/keycloak/keycloak/issues/17273#issuecomment-1456572972 (primarily to add "${KC_HTTP_PORT}")
# Commenting inspired by https://tldp.org/LDP/abs/html/devref1.html#DEVTCP

# Open a read/write socket `&3` to the keycloak API
exec 3<>"/dev/tcp/localhost/${KC_HTTP_PORT}"

# Send a GET request to /health/ready via the opened socket and write to the temporary file `&3`
echo -e "GET /health/ready HTTP/1.1\nhost: localhost:${KC_HTTP_PORT}\n" >&3

# `timeout` - check the API and timeout after 1 second if no response
# `grep` - search for the first instance of 'status' in the API response
# `grep` - search for the first instance of 'UP' in the API response
# `myexit` - capture the exit status (`$?`)
timeout --preserve-status 1 cat <&3 | grep -m 1 'status' | grep -m 1 'UP' ; myexit="$?"

# https://tldp.org/LDP/abs/html/io-redirection.html
exec 3<&-  # Close input file descriptor `3`
exec 3>&-  # Close output file descriptor `3`

# Return the API response as `0` or non-`0`
exit "$myexit"
