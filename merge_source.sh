#!/bin/bash

cd src
cat se-ans.f setup.f logic.f output.f input.f control.f | 
awk -F"\\" '{print $1}' | 
awk -F"[^A-Z]+[()][^A-Z]+" '{print $1 $    3}' | 
sed '/^[[:space:]]*$/d' > ../merged_src.f	
