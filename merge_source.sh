#!/bin/bash

cd src
cat se-ans.f utils.f logic.f output.f input.f control.f | 
awk -F"\\" '{print $1}' |  				# Removes '\' comments
awk -F"[^A-Z]+[()][^A-Z]+" '{print $1 $    3}' | 	# Removes '( )' comments
awk '{ printf "%s ", $0 }' |				# Removes newlines
sed 's/\;/\;\n/g' |					# Adds a newline after ;
sed '/^[[:space:]]*$/d' |				# Removes empty lines
sed -e 's/\t/ /g' | tr -s ' ' > ../merged_src.f  	# Squeezes whitespaces
