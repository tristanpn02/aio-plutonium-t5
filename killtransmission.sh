#!/bin/bash
# Wait for transmission-cli to finish downloading
while transmission-remote -l | grep -q "downloading"; do
  sleep 10
done

# Stop transmission-cli when done
transmission-remote -t all --stop
