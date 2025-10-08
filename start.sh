#!/bin/bash

# Make sure the log directory exists
mkdir -p /var/log/logmein-hamachi

# Start the Hamachi daemon in the background
/opt/logmein-hamachi/bin/hamachid

# Wait for the daemon to start and create its PID file
# The init script waits for 3 seconds, so we'll do the same.
sleep 3

# Check if the daemon is running
if ! pidof hamachid > /dev/null; then
    echo "Failed to start hamachid."
    exit 1
fi

echo "Hamachi daemon started."

# Execute initial hamachi commands if provided as arguments
if [ $# -gt 0 ]; then
    hamachi "$@"
fi

echo "Hamachi container is running. Attach to the container to run hamachi commands."
# Keep the container running
tail -f /dev/null