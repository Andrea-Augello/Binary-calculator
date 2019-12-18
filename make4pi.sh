#!/bin/bash

pi3bp_linker="	MEMORY
	{
		ram : ORIGIN = 0x8000, LENGTH = 0x1000000
	}
	SECTIONS
	{
		.text : { *(.text*) } > ram
		.bss : { *(.bss*) } > ram
	}"

function assemble {
	echo "Assembling file into an executable and linkable format object file...";
	arm-none-eabi-as "$name.s" -o "$name.o" 
	echo "	arm-none-eabi-as $name.s -o $name.o" 
}

function write_linker {
	echo "Creating linker..."
	 
	echo "$pi3bp_linker";
	echo "$pi3bp_linker" > kernel7.ld
}

function link {
	echo "Linking object file to resolve addresses...";
	arm-none-eabi-ld -T "$2" "$1.o" -o "$1.elf" 
	echo "	arm-none-eabi-ld -T $2 $1.o -o $1.elf" 
}

function makebin {
	echo "Extracting machine language code from the finalized ELF file in binary format...";
	arm-none-eabi-objcopy  "$1.elf" -O "binary" "$1.bin" 
	echo "	arm-none-eabi-objcopy $1.elf -O binary $1.bin"
}

function rename {
	echo "Renaming binary file to follow bootstrap conventions..."
	mv  "$1.bin" "kernel7.img"
	echo "	mv  $1.bin kernel7.img"
}

function clean {
	echo "Cleaning up intermediate files...";
	rm $1".o";
	rm $1".elf"
	if [  "$custom_linker"=false ];
	then
		rm kernel7.ld
	fi
}




if [ $# -eq 0 ];
then
	echo "Usage: ./make4pi.sh [-v][-l <custom_linker.ld>] <source.s>";
	exit 1;
fi

intermediate_files=false;
custom_linker=false;
linker="kernel7.ld";

while [ $# -gt 1 ]
do
	argument="$1";
	case $argument in
		-v)
			intermediate_files=true;
			echo "The intermediate files will be kept.";
			shift;
			;;
		-l)
			custom_linker=true;
			shift;
			linker=$1;
			shift;
			;;
	esac
done

name=`echo $1 | awk -F"." '{print $1}'` ;

assemble "$name";
if [ "$custom_linker"=false ]
then
	write_linker;
fi
link "$name" "$linker";
makebin "$name";
rename "$name";

if [ "$intermediate_files" = false ];
then
	clean "$name"
fi


echo "Finished!" ;
exit 1 
