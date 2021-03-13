#!/bin/bash

while [[ "$#" -gt 0 ]]; do case $1 in
  -d|--dry-run) DRY_RUN="--dry-run --debug";;
  -n|--name) NAME="$2"; shift;;
  *) echo "Error, unknown parameter passed: $1."; exit 1;;
esac; shift; done

# Check to see if the name has been given
if [[ -z $NAME ]] || [[ $NAME =~ ^-.* ]]; 
  then echo "Error, name is not set."; exit 1;
fi

echo "Name = $NAME"
echo "Dry-run? $DRY_RUN"
