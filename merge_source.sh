#!/bin/bash

cd src
cat se-ans.f setup.f logic.f output.f input.f control.f | 
awk -F"\\" '{print $1}' |  				# Removes '\' comments
awk -F"[^A-Z]+[()][^A-Z]+" '{print $1 $    3}' | 	# Removes '( )' comments
awk '{ printf "%s ", $0 }' |				# Removes newlines
sed 's/\;/\;\n/g' |					# Adds a newline after ;
sed '/^[[:space:]]*$/d' > ../merged_src.f   
