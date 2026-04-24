#!/usr/bin/env bash
# QueueSync installation script
# This script will build and install the binary

# SPM is bypassed to support the CLI-only ~5GB constraint
swiftc Sources/QueueSync/*.swift -O -o queuesync
cp queuesync /usr/local/bin/queuesync
echo "QueueSync installed successfully!"
