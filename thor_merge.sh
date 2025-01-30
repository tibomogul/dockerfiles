#!/bin/bash
echo "My version: $1"
cat "$1"
echo "Rails version: $2"
cat "$2"
git merge-file "$2" "/dev/null" "$1"

