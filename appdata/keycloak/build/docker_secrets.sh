#!/bin/bash

# Basic support for passing the db password as a mounted file. Or any other KC_ variable,
# really.
# Looks up environment variables like FILE__KC_*, reads the specified file and exports
# the content to KC_*
# e.g. FILE__KC_DB_PASSWORD -> KC_DB_PASSWORD

# Find suitable variables
lines="$(printenv | grep -o "FILE__.*=")"  # Note, leaves hanging `=`
# Split into array
mapfile -t vars <<< "$lines"  # https://www.shellcheck.net/wiki/SC2206

# Enumerate variable names
for var in "${vars[@]}"; do
    # Remove trailing `=`
    var="${var%=}"

    # Output variable, trim the FILE__ prefix
    # e.g. FILE__KC_DB_PASSWORD -> KC_DB_PASSWORD
    outvar="${var#FILE__}"

    # Variable content = file path
    file="${!var}"

    # Empty value -> warn but don't fail
    if [[ -z "${file}" ]]; then
        echo "WARN: $var specified but empty"
        continue
    fi

    # File exists
    if [[ -e "${file}" ]]; then
        # Read contents
        content="$(cat "${file}")"
        # Export contents if non-empty
        if [[ -n "${content}" ]]; then
            export "${outvar}"="${content}"
            echo "INFO: exported ${outvar} from ${var}"
        # Empty contents, warn but don't fail
        else
            echo "WARN: ${var} -> ${file} is empty"
        fi
    # File is expected but not found. Very likely a misconfiguration, fail early
    else
        echo "ERR: ${var} -> file '${file}' not found"
        exit 1
    fi
done
