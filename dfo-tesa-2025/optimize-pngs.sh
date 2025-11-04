#!/bin/bash

# Script to optimize all PNG files in *_files/ folders and images/ folder using optipng in parallel

# Number of parallel jobs (default to number of CPU cores)
JOBS=${1:-$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)}

echo "Running optipng with $JOBS parallel jobs..."

# Find all PNG files in directories matching *_files/ pattern and images/ folder, process in parallel
{
    find . -type d -name '*_files' -exec find {} -type f -name '*.png' \;
    find ./images -type f -name '*.png' 2>/dev/null
} | xargs -P "$JOBS" -I {} sh -c 'echo "Optimizing: {}"; optipng -strip all "{}"'

echo "Done optimizing PNG files!"
