#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")/client-end"

echo "Loading azd .env file from current environment"
azd env get-values | awk -F= '{print $1"="$2}' > .env