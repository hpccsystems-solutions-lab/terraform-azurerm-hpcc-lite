#!/bin/sh
name=$(basename `pwd`)
if [ -d "data" ] && [ -f "data/config.json" ]; then
   echo "Complete! $name is already deployed";exit 0;
else 
  if [ ! -d "data" ];then mkdir data; fi
  touch data/config.json
fi
