#!/bin/bash

# Execute 'jenv getjava' command and capture its output
var=$(jenv getjava)

# Check if the specified Java executable exists
if [ -x "$var/bin/java" ]; then
    # Execute the Java program with provided arguments
    "$var/bin/java" "$@"
else
    # Print an error message if the specified Java executable does not exist
    echo "There was an error:"
    echo "$var"
fi