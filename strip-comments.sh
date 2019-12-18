#!/bin/bash

cat "$1" | awk -F"\\" '{print $1}' | awk -F"[()]" '{print $1 $3}' > "stripped_$1"
