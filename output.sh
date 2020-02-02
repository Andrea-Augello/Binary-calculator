#!/bin/bash

cd src
cat se-ans.f setup.f logic.f output.f input.f control.f > ../merged_src.f
cd .. 
./strip-comments.sh merged_src.f
mv  stripped_merged_src.f merged_src.f
